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
  static let router  = Logger(subsystem: "screens", category: "screens-router")
  static let uikit = Logger(subsystem: "screens", category: "screens-uikit")
  static let swiftui = Logger(subsystem: "screens", category: "screens-swiftui")
}



public final class ScreenController:  ObservableObject {
  /// Let
  public let id: ScreenID = .newScreenID
  public let staticID: ScreenStaticID
  public let alias: String?
  public let screenInfo: ScreenInfo

  private(set) weak var viewController: ScreenViewController?

  func set(vc: ScreenViewController) {
    viewController?.delegate = nil
    vc.delegate = self
    viewController = vc
  }
  weak var router: ScreenRouter?

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
  var hasNavigationDestination: Bool = false
  var isPresented: Bool
  var detachedScreen: Bool = false 
  var viewDidLoaded: Bool = false

  /// View Communcation
  let doDismiss = PassthroughSubject<Void, Never>()
  let onScreenAppear = PassthroughSubject<ScreenAppearance, Never>()

  private(set) var appearance: ScreenAppearance? {
    didSet {
      if let appearance, appearance.appearance != .dissapeared {
        parentScreen?.child(appeared: id)

        DispatchQueue.main.async {
          self.onScreenAppear.send(appearance)
        }
        Logger.screens.log("\(self.logID) appear via: \(appearance.description)")
        Screens.shared.screen(kind: .didAppear(detached: self.detached, appearance: appearance), for: self)
      } else if appearance?.appearance == .dissapeared {
        parentScreen?.child(disappeared: id)
        Screens.shared.screen(kind: .didDisappear, for: self)
        Logger.screens.log("\(self.logID) disappeared poped: \(Self.lastDisaparedWasPopped)")
      }
    }
  }
  private static var lastDisaparedWasPopped: Bool = false

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

  var readyToRoute: Bool = false {
    didSet {
      if readyToRoute {
        router?.screenReadyToRoute()
      }
    }
  }


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
    parentScreen?.child(removed: id)
    parentScreen?.child(disappeared: id)
    Screens.shared.screen(removed: id)
  }

  //MARK: SwiftUI
  func onNavigationDestinationAppear() {
    guard isAppeared, !detached, let viewController, viewController.outerNC == nil, innerNC != nil else { return }
    Logger.swiftui.log("\(self.logID) screenDestinationOnAppear")
    screenDidAppearAgain()
  }

  func onAppear() {
    Logger.swiftui.log("\(self.logID) onAppear \(self.detached ? "(detached)" : "") \(self.isPresented ? "(presented)" : "")")
    readyToRoute = false

    if detachedScreen {
      if appearance == nil {
        screenDidAppearFirstTime()
      } else if let appearance, appearance.appearance == .dissapeared {
        screenDidAppearAgain()
      }
      readyToRoute = true
    }
  }

  func onDissappear() {
    Logger.swiftui.log("\(self.logID) onDissappear")

    if detachedScreen   {
      screenDidDisappear()
      readyToRoute = false
    }
  }


  func onIsPresentedChanged(_ newValue: Bool) {
    Logger.swiftui.log("\(self.logID) onIsPresentedChanged \(newValue)")
    self.isPresented = newValue
  }

  func set(parent: ScreenID, address: Int) {
    guard parent != .zero, parentScreenID == nil else { return }
    self.parentScreenID = parent
    self.parentAddress = address
    parentScreen?.child(created: id)
  }

  /// ``ScreenProxy``
  public func dismiss() {
    doDismiss.send()
  }

  private func doFirstAppearanceIfNeedWithDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
      self?.doFirstAppearanceIfNeed()
    }
  }

  private func doFirstAppearanceIfNeed() {
    guard let parentScreen, appearance == nil && detached else { return }

    // Apperance will happened when switched to this screen
    if parentScreen.isTabBar  { return }

    // Screen can appear only if parent appeared
    if parentScreen.appearance == nil { return }

    screenDidAppearFirstTime()
  }

  // MARK: Screens
  func screenDidDisappear() {
    guard let appearance, appearance.appearance != .dissapeared else { return }

    if let firstAppearanceStack,
       firstAppearanceStack.index > 0,
       firstAppearanceStack != stack {
      Self.lastDisaparedWasPopped = true
    } else {
      Self.lastDisaparedWasPopped = false
    }
    self.appearance!.appearance = .dissapeared
  }

  func onParentsAppeared() {
//    guard let parentScreen, swiftUIIsAppered, appearance == nil && detached else { return }
//
//    // Apperance will happened when switched to this screen
//    if parentScreen.isTabBar  { return }
//
//    // Screen can appear only if parent appeared
//    if parentScreen.appearance == nil { return }
//
//    screenDidAppearAgain()
  }

  func screenDidAppearFirstTime() {
    guard appearance == nil, let viewController else { return }

    var newAppearance = ScreenAppearance()
    newAppearance.count += 1
    newAppearance.lastAppearAt = CFAbsoluteTimeGetCurrent()

    if innerNC != nil, !hasNavigationDestination {
      log(error: "has inner navigation controller but not a scree navigation destination")
    }

    if let parentScreen, parentScreen.viewController?.parent == viewController.parent || parentScreen.isTabBar {
      newAppearance.nested = true
    } else if detached {
      newAppearance.nested = true
    }

    let stack = self.stack
    if let stack, stack.index > 0 {
      newAppearance.firstAppearance = .pushed
    } else if viewController.sheetPresentationController != nil,
              viewController.presentingViewController != nil {
      newAppearance.firstAppearance = .sheet
    } else if viewController.presentingViewController != nil {
      newAppearance.firstAppearance = .fullscreen
    } else if stack != nil, Self.lastDisaparedWasPopped {
      newAppearance.firstAppearance =  .poppedTo
    } else {
      newAppearance.firstAppearance = .other
    }
    newAppearance.appearance = newAppearance.firstAppearance

    self.firstAppearanceStack = stack
    self.appearance = newAppearance

  }

  func screenDidAppearAgain() {
    guard var appearance else { return }

    appearance.count += 1
    appearance.lastAppearAt = CFAbsoluteTimeGetCurrent()
    appearance.appearance = Self.lastDisaparedWasPopped ? .poppedTo : .other
    self.appearance = appearance
  }

  // MARK: Childs
  private func child(appeared id: ScreenID){
    visibleChilds.insert(id)
  }

  private func child(disappeared id: ScreenID){
    visibleChilds.remove(id)
  }

  private func child(created id: ScreenID){
    childs.insert(id)
  }

  private func child(removed id: ScreenID){
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

