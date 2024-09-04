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
  static let uikit = Logger(subsystem: "screens", category: "uikit")
  static let swiftui = Logger(subsystem: "screens", category: "swiftui")
}

public final class ScreenController: UIViewController, ObservableObject {
  /// Let
  public let id: ScreenID = .newScreenID
  public let staticID: ScreenStaticID
  public let alias: String?
  public let screenInfo: ScreenInfo

  /// Dynamic Let
  public private(set) var parentScreenID: ScreenID?

  func set(parent: ScreenID) {
    guard parent != .zero, parentScreenID == nil else { return }
    self.parentScreenID = parent
  }
  /// Var
  var tag: ScreenTag?
  @Published var hasNavigationDestination: Bool = false
  var isPresented: Bool

  /// View Communcation
  let doDismiss = PassthroughSubject<Void, Never>()
  let onScreenAppear = PassthroughSubject<ScreenAppearance, Never>()

  var detached: Bool { parent == nil }
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
        Logger.swiftui.debug("\(self.logID) set new pushOuter \(pushOuter.debugDescription)")
      } else  {
        Logger.swiftui.debug("\(self.logID) clear pushOuter")
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
        Logger.swiftui.debug("\(self.logID) set new pushNavigationDestination \(pushNavigationDestination.debugDescription)")
      } else  {
        Logger.swiftui.debug("\(self.logID) clear pushNavigationDestination")
      }
    }
  }

  /// ``CustomStringConvertable``
  public override var description: String { "\(logID)-\(self.vcID.pointer)" }
  public override var debugDescription: String { "\(logID)-\(self.vcID.pointer)" }

  var logID: String { "\(staticID.type)[\(id)]" }

  var innerNC: UINavigationController? {
    parent?.children.first { $0 is UINavigationController } as? UINavigationController
  }
  var outerNC: UINavigationController? {
    navigationController
  }
  var rootNC: UINavigationController? {
    navigationController?.navigationController
  }

  var isTabBar: Bool {
    parent?.children.first { $0 is UITabBarController } != nil
  }

  /// ``ScreenProxy``
  public var stack: StackProxy? {
    if let rootNC, let outerIndex = outerNC?.index(of: self), outerIndex == 0 {
      let index = rootNC.index(of: self) ?? -1
      return  StackProxy(stackID: rootNC.vcID,
                         index: index,
                         kind: .root)
    } else if let outerNC {
      let index = outerNC.index(of: self) ?? -1
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

  private(set) var isAppearing: Bool = false
  private(set) var isDisappearing: Bool = false
  private var notifiedWillPoppedBack = false
  private(set) var firstAppearanceStack: StackProxy?

  init(staticID: ScreenStaticID, alias: String?, parentScreenID: ScreenID? = nil, isPresented: Bool = false) {
    self.staticID = staticID
    self.parentScreenID = parentScreenID
    self.alias = alias
    self.isPresented = isPresented
    self.screenInfo = ScreenInfo(id: id, type: staticID.type)
    Logger.screens.debug("\(staticID.type)[\(self.id)] init")
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    Logger.screens.debug("\(self.logID) deinit")
    fullcreen = nil
    sheet = nil
    pushOuter = nil
    pushNavigationDestination = nil
    Screens.shared.screen(removed: id)
  }

  //MARK: SwiftUI
  func screenDestinationOnAppear() {
    hasNavigationDestination = true
    guard !isAppearing, innerNC != nil else { return }
    Logger.swiftui.debug("\(self.logID) screenDestinationOnAppear")

    if !appearance.isFirstAppearance {
      screenDidAppear()
    }
  }

  func screenDestinationOnDissappear() {
    guard innerNC != nil else { return }
    Logger.swiftui.debug("\(self.logID) screenDestinationOnDisappear")
    screenDidDisappear()
  }

  func onAppear() {
    isAppearing = true
    Logger.swiftui.debug("\(self.logID) onAppear \(self.detached ? "(detached)" : "") \(self.isPresented ? "(presented)" : "")")

    if appearance.isFirstAppearance  {
      detectFirstAppearance()
    } else {
      screenDidAppear()
    }
  }

  func onDissappear() {
    Logger.swiftui.debug("\(self.logID) onDissappear")
    screenDidDisappear()
  }

  func onIsPresentedChanged(_ newValue: Bool) {
    Logger.swiftui.debug("\(self.logID) onIsPresentedChanged \(newValue)")
    self.isPresented = newValue
  }

  /// ``ScreenProxy``
  public func dismiss() {
    doDismiss.send()
  }

  //MARK: UIKit

  public override func viewDidLoad() {
    super.viewDidLoad()
    Logger.uikit.debug("\(self.logID) viewDidLoad")
    Screens.shared.screen(created: self)
  }

  public override func viewWillAppear(_ animated: Bool) {
    isAppearing = true
    /// isDisappearing  - its case when cancel swipe gesture for poping back in stack
    if appearance.isFirstAppearance || isDisappearing  {
      screenDidAppear()
    }
    Logger.uikit.debug("\(self.logID) viewWillAppear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)] ")
    super.viewWillAppear(animated)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    isDisappearing = true
    notifyPreviousScreensToBePoped()
    Logger.uikit.debug("\(self.logID) viewWillDisappear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    super.viewWillDisappear(animated)
  }

  public override func viewDidAppear(_ animated: Bool) {
    isAppearing = false
    isDisappearing = false
    Logger.uikit.debug("\(self.logID) viewDidAppear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    super.viewDidAppear(animated)
  }

  public override func viewDidDisappear(_ animated: Bool) {
    isDisappearing = false
    isAppearing = false
    Logger.uikit.debug("\(self.logID) viewDidDisappear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    Screens.shared.screen(stateUpdated: self)
    super.viewDidDisappear(animated)
  }

  public override func didMove(toParent parent: UIViewController?) {
    Logger.uikit.debug("\(self.logID) didMove to:\(parent)")
    super.didMove(toParent: parent)
  }

  public override func willMove(toParent parent: UIViewController?) {
    Logger.uikit.debug("\(self.logID) willMove to:\(parent)")
    super.willMove(toParent: parent)
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

  private func screenDidDisappear() {
    guard appearance.appearance != .dissapeared else { return }
    Logger.screens.debug("\(self.logID) disappeared")
    self.appearance.appearance = .dissapeared
    Screens.shared.screen(kind: .didDisappear, for: self)
    Screens.shared.screen(stateUpdated: self)
  }

  private func screenDidAppear() {

    if appearance.isFirstAppearance {

      if parentScreen?.parent == parent || !self.isPresented {
        appearance.nested = true
      }

      if let stack, stack.index > 0 {
        appearance.firstAppearance = .pushed
        self.firstAppearanceStack = stack
      } else if sheetPresentationController != nil, presentingViewController != nil {
        appearance.firstAppearance = .sheet
      } else if presentingViewController != nil {
        appearance.firstAppearance = .fullscreen
      } else {
        appearance.firstAppearance = .other
      }

      if let innerNC, !hasNavigationDestination {
        log(error: "has inner navigation controller but not a scree navigation destination")
      }

      appearance.appearance = appearance.firstAppearance
    } else {
      if self.notifiedWillPoppedBack {
        self.appearance.appearance = .poppedTo
      } else if self.appearance.nested,
                let parentScreen,
                parentScreen.notifiedWillPoppedBack {
        self.appearance.appearance = .poppedTo
      } else {
        self.appearance.appearance = .other
      }
    }

    appearance.count += 1
    isAppearing = false
    isDisappearing = false

    DispatchQueue.main.async {
      Logger.screens.debug("\(self.logID) appear via: \(self.appearance.description)")
      self.onScreenAppear.send(self.appearance)
      self.notifiedWillPoppedBack = false
      Screens.shared.screen(kind: .didAppear(detached: self.detached, appearance: self.appearance), for: self)
      Screens.shared.screen(stateUpdated: self)
      self.screenshot()
    }
  }

  private func notifyPreviousScreensToBePoped() {
    guard let firstAppearanceStack, appearance.firstAppearance == .pushed else { return }

    func notify(_ vcs: [UIViewController]) {
      for vc in vcs {
        if let screenVC = vc as? ScreenController, vc != self {
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
}

//MARK: ScreenBrowser+
extension ScreenController {

  func log(error message: String) {
    Logger.screens.error("[\(self.logID)] \(message)")
    Screens.shared.screen(error: "[\(self.logID)] \(message)")
  }

  var nodeDebugName: String {
    "[\(id)]"
  }

  var nodeDebugDescription: String {
    "\(nodeDebugName) parent:\(parentScreenID?.description ?? "")"
  }

  var dto: ScreenLiveInfo {
    ScreenLiveInfo(screenID: id,
                   staticID: staticID,
                   alias: alias,
                   tag: tag,
                   parentScreenID: parentScreenID,
                   hasParentVC: parent != nil,
                   hasNavigationDestination: hasNavigationDestination,
                   size: ScreeSize(size: parent?.view.frame.size ?? view.frame.size),
                   stack: stack,
                   appearance: appearance,
                   isPresented: isPresented,
                   info: "")
  }

  func screenshot() {
    guard let parent else { return }
    UIGraphicsBeginImageContext(parent.view.frame.size)
    parent.view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let data = image?.jpegData(compressionQuality: 1) else { return }
    let screenShot = ScreenShoot(screenID: id, data: data)
    Screens.shared.screen(shot: screenShot)
  }
}

extension ScreenController {
  static let root = ScreenController(staticID: .init(type: "App", file: ""), alias: nil)
}

