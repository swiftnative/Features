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
  public private(set) var visibleChilds = Set<ScreenID>()

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
  private static var lastDisaparedWasPopped: Bool = false

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
  var isUpdatingAppearance: Bool = false

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
    parentScreen?.child(disappeared: id)
    Screens.shared.screen(removed: id)
  }

  //MARK: SwiftUI
  func onNavigationDestinationAppear() {
    Logger.swiftui.log("\(self.logID) screenDestinationOnAppear")
    hasNavigationDestination = true
    guard !isAppearing else { return }
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
      doFirstAppearanceIfNeedWithDelay()
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
  }

  /// ``ScreenProxy``
  public func dismiss() {
    doDismiss.send()
  }

  // MARK: Private Magic
  private func doFirstAppearanceIfNeedWithDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) { [weak self] in
      self?.doFirstAppearanceIfNeed()
    }
  }

  private func doFirstAppearanceIfNeed() {
    guard let parentScreen, appearance == nil && detached else { return }

    // Apperance will happened when switched to this screen
    if parentScreen.isTabBar  { return }

    // Screen can appear only if parent appeared
    if parentScreen.appearance == nil { return }

    screenWillAppear()
  }

  // MARK: Screens
  func screenWillAppear(update: Bool = false) {
    guard !isAppeared || update, !isUpdatingAppearance else { return }
    isUpdatingAppearance = true
    DispatchQueue.main.async { [weak self] in
      self?.updateAppearance()
    }
  }


  func screenWillDisappear() {
    guard let appearance, appearance.appearance != .dissapeared else { return }
    self.appearance!.appearance = .dissapeared
    parentScreen?.child(disappeared: id)

    if let firstAppearanceStack,
          firstAppearanceStack.index > 0,
       firstAppearanceStack != stack {
      Self.lastDisaparedWasPopped = true
    } else {
      Self.lastDisaparedWasPopped = false
    }

    Screens.shared.screen(kind: .didDisappear, for: self)
    Logger.screens.log("\(self.logID) disappeared poped: \(Self.lastDisaparedWasPopped)")
  }


  private func updateAppearance() {
    guard let viewController else { return }

    defer {
      isAppearing = false
      isDisappearing = false
    }

    let isFirstAppearance = self.appearance == nil

    var newAppearance = self.appearance ?? ScreenAppearance()
    newAppearance.count += 1

    if isFirstAppearance {

      if innerNC != nil, !hasNavigationDestination {
        log(error: "has inner navigation controller but not a scree navigation destination")
      }

      if let parentScreen, parentScreen.viewController?.parent == viewController.parent || parentScreen.isTabBar {
        newAppearance.nested = true
      } else if detached {
        newAppearance.nested = true
      }

      if let stack, stack.index > 0 {
        newAppearance.firstAppearance = .pushed
      } else if viewController.sheetPresentationController != nil,
                viewController.presentingViewController != nil {
        newAppearance.firstAppearance = .sheet
      } else if viewController.presentingViewController != nil {
        newAppearance.firstAppearance = .fullscreen
      } else {
        newAppearance.firstAppearance = .other
      }
      newAppearance.appearance = newAppearance.firstAppearance

    } else {
      newAppearance.appearance =  Self.lastDisaparedWasPopped ? .poppedTo : .other
    }

    self.appearance = newAppearance

    /// Sometime there is only place to get correct stack
    setFirstAppearanceStackIfNil()
    parentScreen?.child(appeared: id)
    onScreenAppear.send(newAppearance)

    Logger.screens.log("\(self.logID) appear via: \(newAppearance.description)")
    Screens.shared.screen(kind: .didAppear(detached: self.detached, appearance: newAppearance), for: self)

    isUpdatingAppearance = false
  }

  func setFirstAppearanceStackIfNil() {
    guard firstAppearanceStack == nil else { return }
    self.firstAppearanceStack = stack
  }

  // MARK: Childs
  private func child(appeared id: ScreenID){
    visibleChilds.insert(id)
  }

  private func child(disappeared id: ScreenID){
    visibleChilds.remove(id)
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

