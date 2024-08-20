//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os
import ScreensBrowser
import SwiftUI
import Combine

public final class ScreenController: UIViewController, ObservableObject {
  typealias Dismiss = () -> Void
  public let id: ScreenID = .newScreenID
  public let staticID: ScreenStaticID
  let alias: String?
  var tag: ScreenTag?
  public var parentScreenID: ScreenID?
  var state: ScreenState
  private var isFirstAppear: Bool = true
  private var isPresented: Bool { presentingViewController != nil }
  var dismissAction: DismissAction? { environment.dismiss }
  var info: String = ""
  var stack: NavigationStackInfo?
  var hasInnerNavigationDestination: Bool = false

  let logger = Logger(subsystem: "screens", category: "screens")

  var screens: Screens { Screens.shared }
  

  public internal(set) var environment: EnvironmentValues = EnvironmentValues()

  var environmentInfo: EnvironmentInfo {
    EnvironmentInfo(isPresented: environment.isPresented)
  }

  var preferencesInfo: PreferencesInfo {
    PreferencesInfo(innerNaigationDestination: hasInnerNavigationDestination)
  }

  init(staticID: ScreenStaticID, alias: String?) {
    self.staticID = staticID
    self.alias = alias
    self.state = .init()

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private(set) var childrenScreens: [ScreenID] = []

  func onAppear(environment: EnvironmentValues) {
    logger.debug("[\(self.logID)] onAppear")
    self.parentScreenID = environment.screenID == .zero ? nil : environment.screenID
    self.environment = environment
  }

  func screenshot() {
    guard let parent else { return }
    UIGraphicsBeginImageContext(parent.view.frame.size)
    parent.view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let data = image?.jpegData(compressionQuality: 1) else { return }
    let screenShot = ScreenShoot(screenID: id, data: data)
    screens.screen(shot: screenShot)
  }

  func onDissappear() {
    logger.debug("[\(self.logID)] onDissappear")
  }

  func onIsPresentedChanged(environment: EnvironmentValues) {
    logger.debug("[\(self.logID)] onIsPresentedChanged \(environment.isPresented)")
    self.environment = environment
    screens.screen(stateUpdated: self)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    logger.debug("[\(self.logID)] viewDidLoad")
  }

  public func dismiss() {
    if environment.isPresented {
      dismissAction?()
    } else {
      self.dismiss(animated: true)
    }
  }

  deinit {
    logger.debug("[\(self.logID)] deinit")
    screens.screen(removed: id)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    logger.debug("[\(self.logID)] viewDidAppear")
    guard state.isAppeared == false else { return }

    state.isAppeared = true
    state.isPresented = isPresented

    if isFirstAppear {
      isFirstAppear = false
      screens.screen(created: self)
    }
    screens.screen(kind: .didAppear, for: self)
    update()
    screens.screen(stateUpdated: self)
    screenshot()
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    logger.debug("[\(self.logID)] viewDidDisappear")
    self.state.isAppeared = false
    screens.screen(kind: .didDisappear, for: self)
    screens.screen(stateUpdated: self)
  }

  public override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    logger.debug("[\(self.logID)] didMove to:\(parent)")
    update()
    screens.screen(stateUpdated: self)
  }

  public override var debugDescription: String {
    "\(self)[\(staticID.type)-\(id)]"
  }

  var logID: String {
    "\(staticID.type)-\(id)"
  }
}


extension ScreenController {

  var nodeDebugName: String {
    "[\(id)]"
  }

  var nodeDebugDescription: String {
    "\(nodeDebugName) \(state) parent:\(parentScreenID?.description ?? "")"
  }

  var dto: ScreenLiveInfo {
    ScreenLiveInfo(screenID: id,
                   staticID: staticID,
                   alias: alias,
                   tag: tag,
                   parentScreenID: parentScreenID,
                   hasParentVC: parent != nil,
                   state:  state,
                   size: ScreeSize(size: parent?.view.frame.size ?? view.frame.size),
                   stack: stack,
                   children: childrenScreens,
                   environment: environmentInfo,
                   preferences: preferencesInfo,
                   info: info)
  }

  func fillStackInfo() {

    if let outerNC, let parent {
      let index = outerNC.viewControllers.firstIndex(of: parent) ?? -1
      self.stack = NavigationStackInfo(stackID: outerNC.vcID,
                                       index: index,
                                       kind: .outer)
    } else if let innerNC {
      self.stack = NavigationStackInfo(stackID: innerNC.vcID,
                                       index: 0,
                                       kind: .inner)
    } else {
      self.stack = nil
    }
  }

  func fillInfo() {

    self.info = ""

    func addInfo(_ title: String, _ vc: UIViewController?) {
      guard let vc else { return }
      self.info += "**\(title)**\n\(vc.description)\n\n"
    }

    addInfo("Presenting", presentingViewController)
    addInfo("Presented", presentedViewController)
    addInfo("Parent", parent)
    addInfo("Navigation Parent", navigationController?.parent)
  }

  func update() {
    fillStackInfo()
    fillInfo()
  }
}

extension ScreenController {
  static let root = ScreenController(staticID: .init(type: "App", file: ""), alias: nil)
}

