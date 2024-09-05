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
  var outerNC: UINavigationController? { viewController?.outerNC }
  var rootNC: UINavigationController? { viewController?.rootNC }
  var isTabBar: Bool { viewController?.isTabBar ?? false }
  var detached: Bool { viewController?.detached ?? true }
  var parentVC: UIViewController? { viewController?.parent }

  /// Dynamic Let
  public private(set) var parentScreenID: ScreenID?
  public private(set) var parentAddress: Int?

  func set(parent: ScreenID, address: Int) {
    guard parent != .zero, parentScreenID == nil else { return }
    self.parentScreenID = parent
    self.parentAddress = address
  }
  /// Var
  var tag: ScreenTag?
  @Published var hasNavigationDestination: Bool = false
  var isPresented: Bool

  /// View Communcation
  let doDismiss = PassthroughSubject<Void, Never>()
  let onScreenAppear = PassthroughSubject<ScreenAppearance, Never>()

  private(set) var appearance = ScreenAppearance()

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

    if let rootNC, let outerIndex = viewController.indexInOuterNC, outerIndex == 0 {
      let index = viewController.indexInRootNC ?? -1
      return  StackProxy(stackID: rootNC.vcID,
                         index: index,
                         kind: .root)
    } else if let outerNC {
      let index = viewController.indexInOuterNC ?? -1
      return  StackProxy(stackID: outerNC.vcID,
                         index: index,
                         kind: .outer)
    } else if let innerNC, hasNavigationDestination {
      return StackProxy(stackID: innerNC.vcID,
                        index: 0,
                        kind: .inner)
    } else {
      return nil
    }
  }

  var parentScreen: ScreenController? {
    guard let parentScreenID else { return nil }
    return Screens.shared.screen(by: parentScreenID)
  }

  var isAppearing: Bool = false
  var isDisappearing: Bool = false
  var firstAppearanceStack: StackProxy?
  var didLoad = false

  init(staticID: ScreenStaticID, alias: String?, parentScreenID: ScreenID? = nil, isPresented: Bool = false) {
    self.staticID = staticID
    self.parentScreenID = parentScreenID
    self.alias = alias
    self.isPresented = isPresented
    self.screenInfo = ScreenInfo(id: id, type: staticID.type)
    Logger.screens.debug("\(staticID.type)[\(self.id)] init \(self.address.pointer)")
  }

  deinit {
    Logger.screens.log("\(self.logID) deinit \(self.address.pointer)")
    Screens.shared.screen(removed: id)
  }

  //MARK: SwiftUI
  func screenDestinationOnAppear() {
    hasNavigationDestination = true
    guard !isAppearing, innerNC != nil else { return }
    Logger.swiftui.log("\(self.logID) screenDestinationOnAppear")

    if !appearance.isFirstAppearance {
      screenDidAppear()
    }
  }

  func screenDestinationOnDissappear() {
    guard innerNC != nil else { return }
    Logger.swiftui.log("\(self.logID) screenDestinationOnDisappear")
    screenDidDisappear()
  }

  func onAppear() {
    isAppearing = true
    Logger.swiftui.log("\(self.logID) onAppear \(self.detached ? "(detached)" : "") \(self.isPresented ? "(presented)" : "")")

    if appearance.isFirstAppearance  {
      detectFirstAppearance()
    } else {
      screenDidAppear()
    }
  }

  func onDissappear() {
    Logger.swiftui.log("\(self.logID) onDissappear")
    screenDidDisappear()
  }

  func onIsPresentedChanged(_ newValue: Bool) {
    Logger.swiftui.log("\(self.logID) onIsPresentedChanged \(newValue)")
    self.isPresented = newValue
  }

  /// ``ScreenProxy``
  public func dismiss() {
    doDismiss.send()
  }

  // MARK: Private Magic
  private func detectFirstAppearance() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)) { [weak self] in
      self?.doFirstAppearanceIfNeed()
    }
  }

  private func doFirstAppearanceIfNeed() {
    guard appearance.isFirstAppearance && detached else { return }

    if let parentScreen, parentScreen.isTabBar {
      return // apperance will happened when switched to this screen
    }

    screenDidAppear()
  }

  func screenDidDisappear() {
    guard appearance.appearance != .dissapeared else { return }
    Logger.screens.log("\(self.logID) disappeared")
    self.appearance.appearance = .dissapeared
    Screens.shared.screen(kind: .didDisappear, for: self)
    Screens.shared.screen(stateUpdated: self)
  }

  func screenDidAppear() {
    guard let viewController else { return }

    if appearance.isFirstAppearance {

      if parentScreen?.viewController?.parent == viewController.parent || !self.isPresented {
        appearance.nested = true
      }

      if let stack, stack.index > 0 {
        appearance.firstAppearance = .pushed
        self.firstAppearanceStack = stack
      } else if viewController.sheetPresentationController != nil,
                viewController.presentingViewController != nil {
        appearance.firstAppearance = .sheet
      } else if viewController.presentingViewController != nil {
        appearance.firstAppearance = .fullscreen
      } else {
        appearance.firstAppearance = .other
      }

      if innerNC != nil, !hasNavigationDestination {
        log(error: "has inner navigation controller but not a scree navigation destination")
      }

      appearance.appearance = appearance.firstAppearance
    } else {
      if viewController.notifiedWillPoppedBack {
        self.appearance.appearance = .poppedTo
      } else if self.appearance.nested,
                let parentScreen,
                let parentVC = parentScreen.viewController,
                parentVC.notifiedWillPoppedBack {
        self.appearance.appearance = .poppedTo
      } else {
        self.appearance.appearance = .other
      }
    }

    appearance.count += 1
    isAppearing = false
    isDisappearing = false

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      Logger.screens.log("\(self.logID) appear via: \(self.appearance.description)")
      self.onScreenAppear.send(self.appearance)
      self.viewController?.notifiedWillPoppedBack = false
      Screens.shared.screen(kind: .didAppear(detached: self.detached, appearance: self.appearance), for: self)
      Screens.shared.screen(stateUpdated: self)
      self.screenshot()
    }
  }

  func notifyPreviousScreensToBePoped() {
    guard let firstAppearanceStack, appearance.firstAppearance == .pushed else { return }

    func notify(_ vcs: [UIViewController]) {
      for vc in vcs {
        if let screenVC = vc as? ScreenViewController, screenVC != self.viewController {
          screenVC.notifiedWillPoppedBack = true
        } else if !vc.children.isEmpty {
          notify(vc.children)
        }
      }
    }

    switch firstAppearanceStack.kind {
    case .inner:
      Logger.screens.error("\(self.logID) can't be popped from inner stack")
      break
    case .outer:
      guard let outerNC else { return }
      notify(outerNC.viewControllers)
      guard let ncParent = outerNC.parent else { return }
      notify(ncParent.children)
    case .root:
      guard let rootNC else { return }
      notify(rootNC.viewControllers)
      guard let ncParent = rootNC.parent else { return }
      notify(ncParent.children)
    }
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

