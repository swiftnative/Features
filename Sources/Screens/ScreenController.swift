//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os
import ScreensBrowser
import SwiftUI
import Combine

extension Logger {
  static let screens  = Logger(subsystem: "screens", category: "screens")
  static let uikit = Logger(subsystem: "screens", category: "screens-uikit")
  static let swiftui = Logger(subsystem: "screens", category: "screens-swiftui")
}

public final class ScreenController:  ObservableObject {
  /// Let
  public let id: ScreenID = .newScreenID
  public let staticID: ScreenStaticID
  public let alias: String?
  public let screenInfo: ScreenInfo

  weak var viewController: ScreenViewController?

  var innerNC: UINavigationController? { viewController?.innerNC }
  var outerNC: UINavigationController? {
    if detached {
      return parentScreen?.innerNC
    } else {
      return viewController?.outerNC
    }
  }
  var rootNC: UINavigationController? { viewController?.rootNC }
  var isTabBar: Bool { viewController?.isTabBar ?? false }
  var detached: Bool { viewController?.detached ?? true }
  var parentVC: UIViewController? { viewController?.parent }

  /// Dynamic Let
  public private(set) var parentScreenID: ScreenID?
  public private(set) var parentAddress: Int?
  public private(set) var childs = Set<ScreenID>()

  var parentScreen: ScreenController? {
    guard let parentScreenID else { return nil }
    return Screens.shared.screen(by: parentScreenID)
  }
  var parentAppearance: ScreenAppearance? {
    parentScreen?.appearance
  }

  /// Var
  var tag: ScreenTag?
  @Published var hasNavigationDestination: Bool = false
  var isPresented: Bool

  /// View Communcation
  let doDismiss = PassthroughSubject<Void, Never>()
  let onScreenAppear = PassthroughSubject<ScreenAppearance, Never>()

  private(set) var appearance: ScreenAppearance?

  /// Navigation
  @Published var fullcreen: ScreenAppearRequest?
  @Published var sheet: ScreenAppearRequest?

  @Published var pushOuter: ScreenAppearRequest? {
    willSet {
      if let pushOuter, newValue != nil  {
        Logger.screens.error("[\(self.logID)] unextected pushOuter is not nil (\(pushOuter.debugDescription)), when push \(newValue.debugDescription)")
      }
    }
    didSet {
      if let pushOuter  {
        Logger.swiftui.log("\(self.logID) set new pushOuter \(pushOuter.debugDescription)")
      } else  {
        Logger.swiftui.log("\(self.logID) clear pushOuter")
      }
    }
  }

  @Published var pushNavigationDestination: ScreenAppearRequest? {
    willSet {
      if let pushNavigationDestination, newValue != nil  {
        Logger.screens.error("[\(self.logID)] unextected pushNavigationDestination is not nil (\(pushNavigationDestination.debugDescription)), when push \(pushNavigationDestination.debugDescription)")
      }
    }
    didSet {
      if let pushNavigationDestination  {
        Logger.swiftui.log("\(self.logID) set new pushNavigationDestination \(pushNavigationDestination.debugDescription)")
      } else  {
        Logger.swiftui.log("\(self.logID) clear pushNavigationDestination")
      }
    }
  }

  /// ``CustomStringConvertable``
  public var description: String { viewController?.description ?? logID }
  public var debugDescription: String { description }

  var logID: String { "\(staticID.type)[\(id)]" }

  /// ``ScreenProxy``
  public var stack: StackProxy? {
    guard let viewController else { return nil }

    var outerNC: UINavigationController?
    if detached {
      outerNC = parentScreen?.innerNC
    } else {
      outerNC = viewController.outerNC
    }

    if let rootNC, let outerIndex = viewController.indexInOuterNC, outerIndex == 0 {
      let index = viewController.indexInRootNC ?? -1
      return  StackProxy(nc: rootNC,
                         index: index,
                         kind: .root)
    } else if let outerNC {
      let index = detached ? 0 : viewController.indexInOuterNC ?? -1
      return  StackProxy(nc: outerNC,
                         index: index,
                         kind: .outer)
    } else if let innerNC, hasNavigationDestination {
      return StackProxy(nc: innerNC,
                        index: 0,
                        kind: .inner)
    } else {
      return nil
    }
  }

  var isAppearing: Bool = false
  var isDisappearing: Bool = false
  private var isPopping: Bool = false
  var isAppeared: Bool {
    guard let appearance else { return false }
    return appearance.appearance != .dissapeared
  }
  var firstAppearanceStack: StackProxy?

  var didLoad = false

  init(staticID: ScreenStaticID, alias: String?, parentScreenID: ScreenID? = nil, isPresented: Bool = false) {
    self.staticID = staticID
    self.parentScreenID = parentScreenID
    self.alias = alias
    self.isPresented = isPresented
    self.screenInfo = ScreenInfo(id: id, type: staticID.type)
    Logger.swiftui.debug("\(staticID.type)[\(self.id)] init \(self.address.pointer)")
  }

  deinit {
    Logger.swiftui.log("\(self.logID) deinit \(self.address.pointer)")
    parentScreen?.child(detached: id)
    Screens.shared.screen(removed: id)
  }

  //MARK: SwiftUI
  func onNavigationDestinationAppear() {
    hasNavigationDestination = true
    guard innerNC != nil, !isAppearing else { return }
    Logger.swiftui.log("\(self.logID) screenDestinationOnAppear")
    isAppearing = true
    isDisappearing = false

    screenWillAppear(update: true)
  }
  
  func onAppear() {
    Logger.swiftui.log("\(self.logID) onAppear \(self.detached ? "(detached)" : "") \(self.isPresented ? "(presented)" : "")")

    guard !isAppearing else { return }
    isAppearing = true
    isDisappearing = false
    if appearance == nil {
      screenWillAppearIfNeedWithDelay()
    } else {
      screenWillAppear()
    }
  }

  func onDissappear() {
    Logger.swiftui.log("\(self.logID) onDissappear")
    guard !isDisappearing else { return }
    isDisappearing = true
    isAppearing = false
    screenWillDisappear()
  }


  func onIsPresentedChanged(_ newValue: Bool) {
    Logger.swiftui.log("\(self.logID) onIsPresentedChanged \(newValue)")
    self.isPresented = newValue
  }

  func set(parent: ScreenID, address: Int) {
    guard parent != .zero, parentScreenID == nil else { return }
    self.parentScreenID = parent
    self.parentAddress = address
    self.parentScreen?.child(attached: id)
  }

  /// ``ScreenProxy``
  public func dismiss() {
    doDismiss.send()
  }

  // MARK: Private Magic
  private func screenWillAppearIfNeedWithDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) { [weak self] in
      self?.screenWillAppearIfNeed()
    }
  }

  private func screenWillAppearIfNeed() {
    guard let parentScreen, appearance == nil && detached else { return }

    if parentScreen.isTabBar ||  parentScreen.appearance == nil  {
      return // apperance will happened when switched to this screen
    }

    screenWillAppear()
  }

  private func screenWillDisappearWithDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) { [weak self] in
      self?.onDissappear()
    }
  }

  // MARK: Screens
  func screenWillAppear(update: Bool = false) {
    guard let viewController, (!isAppeared || update) else { return }

    defer {
      isAppearing = false
      isDisappearing = false
    }

    if firstAppearanceStack == nil {
      self.firstAppearanceStack = stack
    }

    if appearance == nil {

      if innerNC != nil, !hasNavigationDestination {
        log(error: "has inner navigation controller but not a scree navigation destination")
      }

      self.appearance = buildFirstAppearance(viewController: viewController,
                                             parentScreen: parentScreen,
                                             stack: stack)
    } else {
      if isPopping {
        self.appearance?.appearance = .poppedTo
        isPopping = false
      } else {
        self.appearance?.appearance = .other
      }
    }

    appearance!.count += 1

    guard let appearance else { fatalError("appearance is nil") }

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.onScreenAppear.send(appearance)
      Logger.screens.log("\(self.logID) appear via: \(appearance.description)")
      Screens.shared.screen(kind: .didAppear(detached: self.detached, appearance: appearance), for: self)
      Screens.shared.screen(stateUpdated: self)
      self.screenshot()
    }
  }

  func screenWillDisappear() {
    guard let appearance, appearance.appearance != .dissapeared else { return }
    self.appearance!.appearance = .dissapeared

    notifyIFPreviousScreensToBePoped()
    Screens.shared.screen(kind: .didDisappear, for: self)
    Screens.shared.screen(stateUpdated: self)
    Logger.screens.log("\(self.logID) disappeared")
  }

  func notifyIFPreviousScreensToBePoped() {
    guard let firstAppearanceStack,
          firstAppearanceStack.index > 0,
          firstAppearanceStack != stack
    else { return }

    let indexToNotify = firstAppearanceStack.index - 1
    Screens.shared.controllers.all()
      .filter { screen in
        screen.firstAppearanceStack?.stackID == firstAppearanceStack.stackID &&
        screen.firstAppearanceStack?.index == indexToNotify
      }
      .forEach { screen in
        screen.isPopping = true
      }
  }

  private func buildFirstAppearance(viewController: UIViewController,
                                    parentScreen: ScreenController?,
                                    stack: StackProxy?) -> ScreenAppearance {
    var appearance = ScreenAppearance()
    if parentScreen?.viewController?.parent == viewController.parent {
      appearance.nested = true
    }

    if let stack, stack.index > 0 {
      appearance.firstAppearance = .pushed
    } else if viewController.sheetPresentationController != nil,
              viewController.presentingViewController != nil {
      appearance.firstAppearance = .sheet
    } else if viewController.presentingViewController != nil {
      appearance.firstAppearance = .fullscreen
    } else {
      appearance.firstAppearance = .other
    }
    appearance.appearance = appearance.firstAppearance
    return appearance
  }

  // MARK: Childs
  private func child(attached id: ScreenID){
    childs.insert(id)
  }

  private func child(detached id: ScreenID){
    childs.remove(id)
  }

  func log(error message: String) {
    Logger.screens.error("[\(self.logID)] \(message)")
    Screens.shared.screen(error: "[\(self.logID)] \(message)")
  }

  var address: Int {
    Int(bitPattern: Unmanaged.passUnretained(self).toOpaque())
  }

}


extension ScreenController {
  static let root = ScreenController(staticID: .init(type: "App", file: ""), alias: nil)
}

