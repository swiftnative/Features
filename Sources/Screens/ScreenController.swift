//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os
import BrowserMessages
import SwiftUI
import Combine

public final class ScreenController: UIViewController, ObservableObject {
  typealias Dismiss = () -> Void
  public let id: ScreenID = ScreenID()
  public let staticID: ScreenStaticID
  let alias: String?
  var tag: ScreenTag?
  public var parentScreenID: ScreenID?
  var state: ScreenState
  private var isFirstAppear: Bool = true
  var environmentID: UUID!
  var dismissAction: DismissAction?
  var info: String = ""
  var stack: NodeStackInfo?

  let logger = Logger(subsystem: "com.example.MyViewController", category: "MyViewController")

  private var screens: Screens { Screens.shared }

  public internal(set) var environment: EnvironmentValues = EnvironmentValues()

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

  func onAppear(parentScreenID: UUID, isPresented: Bool, dismiss: DismissAction?) {
    self.parentScreenID = parentScreenID == .zero ? nil : parentScreenID
    self.dismissAction = dismiss
    self.state.isAppeared = true
    self.state.environemntIsPresented = isPresented
    if isFirstAppear {
      isFirstAppear = false
      self.state.onApperPresented = isPresented
      screens.screen(created: self)
    } else {
      screens.screen(stateUpdated: self)
    }
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
    self.state.isAppeared = false
    screens.screen(stateUpdated: self)
  }

  func onIsPresentedChanged(isPresented: Bool, dismiss: DismissAction?) {
    logger.debug("[\(self.id)] onIsPresentedChanged \(isPresented)")
    self.state.environemntIsPresented = isPresented
    self.dismissAction = dismiss
    screens.screen(stateUpdated: self)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    logger.debug("[\(self.id)] viewDidLoad")
  }

  public func dismiss() {
    if state.environemntIsPresented {
      dismissAction?()
    } else {
      self.dismiss(animated: true)
    }
  }

  deinit {
    logger.debug("[\(self.id)] deinit")
    screens.screen(removed: id)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    state.lastAppeared = CFAbsoluteTimeGetCurrent()
    state.isPresented = presentingViewController != nil
    update()
    screens.screen(stateUpdated: self)
    screenshot()
    logger.debug("[\(self.id)] viewDidAppear")
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    logger.debug("[\(self.id)] viewDidDisappear")
  }


  public override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    logger.debug("[\(self.id)] didMove \(parent)")
    update()
    screens.screen(stateUpdated: self)
  }

  public override var debugDescription: String {
    "\(self)[\(staticID.type)-\(id.uuidString.prefix(5))]"
  }
}


extension ScreenController {

  var nodeDebugName: String {
    "[\(id.uuidString.prefix(5))]"
  }

  var nodeDebugDescription: String {
    "\(nodeDebugName) \(state) parent:\(parentScreenID?.uuidString.prefix(5) ?? "")"
  }

  var dto: ScreenLiveInfo {
    ScreenLiveInfo(screenID: id,
                   staticID: staticID,
                   alias: alias,
                   tag: tag,
                   parentScreenID: parentScreenID,
                   state:  state,
                   size: ScreeSize(size: parent?.view.frame.size ?? view.frame.size),
                   stack: stack,
                   children: childrenScreens,
                   info: info)
  }

  func fillStackInfo() {
    guard let navigationController, let parent else { return  }

    let index = navigationController.viewControllers.firstIndex(of: parent) ?? -1
    self.stack = NodeStackInfo(stackID: navigationController.vcID, index: index)
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

