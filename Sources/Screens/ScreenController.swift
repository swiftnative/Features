//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os
import ScreensBrowser
import SwiftUI
import Combine

public final class ScreenController: UIViewController, ObservableObject {
  /// Let
  public let id: ScreenID = .newScreenID
  public let staticID: ScreenStaticID
  public let alias: String?
  public let screenInfo: ScreenInfo

  /// Dynamic Let
  public var parentScreenID: ScreenID?

  /// Var
  var tag: ScreenTag?
  var hasNavigationDestination: Bool = false
  var state: ViewState

  /// View Communcation
  let doDismiss = PassthroughSubject<Void, Never>()
  let onScreenAppear = PassthroughSubject<ScreenAppearance, Never>()

  let logger = Logger(subsystem: "screens", category: "screens")

  private var detached: Bool { parent == nil }
  private(set) var appearance = ScreenAppearance()

  /// Navigation
  @Published var fullcreen: ScreenAppearRequest?
  @Published var sheet: ScreenAppearRequest?
  @Published var pushOuter: ScreenAppearRequest?
  @Published var pushNavigationDestination: ScreenAppearRequest?

  /// ``CustomStringConvertable``
  public override var description: String { "\(logID)-\(self.vcID.pointer)" }

  var logID: String { "\(staticID.type)[\(id)]" }

  var innerNC: UINavigationController? {
    parent?.children.first { $0 is UINavigationController } as? UINavigationController
  }

  private(set) var isAppearing: Bool = false
  private(set) var isDisappearing: Bool = false
  private var notifiedWillPoppedBack = false

  init(staticID: ScreenStaticID, alias: String?) {
    self.staticID = staticID
    self.alias = alias
    self.state = .init()
    self.screenInfo = ScreenInfo(id: id, type: staticID.type)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    logger.debug("\(self.logID) deinit")
    Screens.shared.screen(removed: id)
  }

  //MARK: View events

  func screenDestinationOnAppear() {
    guard !isAppearing, innerNC != nil else { return }
    logger.debug("\(self.logID) screenDestinationOnAppear")
    appearance.count += 1
    if !appearance.isFirstAppearance {
      screenWillAppear()
    }
  }

  func onAppear() {
    logger.debug("\(self.logID) onAppear \(self.detached ? "(detached)" : "") \(self.state.isPresented ? "(presented)" : "")")
    isAppearing = true
    appearance.count += 1

    if !appearance.isFirstAppearance {
      screenWillAppear()
    }

    state.isAppeared = true
  }

  func onDissappear() {
    logger.debug("\(self.logID) onDissappear")
    self.state.isAppeared = false
    Screens.shared.screen(kind: .didDisappear, for: self)
    Screens.shared.screen(stateUpdated: self)
  }

  // MARK: Public

  public func dismiss() {
    doDismiss.send()
  }

  // MARK: Private

  private func screenWillAppear() {

    if appearance.isFirstAppearance {
      if navigationController != nil {
        appearance.firstAppearance = .pushed
      } else if sheetPresentationController != nil, presentingViewController != nil {
        appearance.firstAppearance = .sheet
      } else if presentingViewController != nil {
        appearance.firstAppearance = .fullscreen
      }
      appearance.appearance = appearance.firstAppearance
    } else {
      if self.notifiedWillPoppedBack {
        self.appearance.appearance = .poppedTo
        self.notifiedWillPoppedBack = false
      } else {
        self.appearance.appearance = .other
      }
    }

    DispatchQueue.main.async {
      self.logger.debug("\(self.logID) will ScreenAppear \(self.appearance.description)")
      self.onScreenAppear.send(self.appearance)
    }

    Screens.shared.screen(kind: .didAppear(detached: detached), for: self)
    Screens.shared.screen(stateUpdated: self)
    screenshot()
  }

  private func notifyIfPoped() {
    guard let navigationController,
          let parent,
          !navigationController.viewControllers.contains(parent) else { return }

    func notifyScreenController(vcs: [UIViewController]) {
      for vc in vcs {
        if let screenVC = vc as? ScreenController {
          screenVC.notifiedWillPoppedBack = true
        }
      }
    }

    notifyScreenController(vcs: navigationController.viewControllers.flatMap { $0.children })

    guard let ncParent = navigationController.parent else { return }

    notifyScreenController(vcs: ncParent.children)
  }


  //MARK: UIViewController Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()
    //    logger.debug("\(self.logID) viewDidLoad")
    Screens.shared.screen(created: self)
    state.isAppeared = true
  }

  public override func viewWillAppear(_ animated: Bool) {
    isAppearing = true
    if appearance.isFirstAppearance {
      screenWillAppear()
    }
    logger.debug("\(self.logID) viewWillAppear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)] ")
    super.viewWillAppear(animated)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    isDisappearing = true
    notifyIfPoped()
    logger.debug("\(self.logID) viewWillDisappear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    super.viewWillDisappear(animated)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isAppearing = false
    isDisappearing = false
    logger.debug("\(self.logID) viewDidAppear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")

  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    isDisappearing = false
    isAppearing = false
    logger.debug("\(self.logID) viewDidDisappear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
  }

  public override func didMove(toParent parent: UIViewController?) {
    if self.parent != parent {
      logger.debug("\(self.logID) didMove to:\(parent)")
      Screens.shared.screen(stateUpdated: self)
    }
   super.didMove(toParent: parent)
  }
}

//MARK: ScreenBrowser+
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
                   hasNavigationDestination: hasNavigationDestination,
                   size: ScreeSize(size: parent?.view.frame.size ?? view.frame.size),
                   stack: stackInfo,
                   appearance: appearance,
                   info: info)
  }

  var stackInfo: NavigationStackInfo? {

    if let outerNC, let parent {
      let index = outerNC.viewControllers.firstIndex(of: parent) ?? -1
      return  NavigationStackInfo(stackID: outerNC.vcID,
                                  index: index,
                                  kind: .outer)
    } else if let innerNC {
      return NavigationStackInfo(stackID: innerNC.vcID,
                                 index: 0,
                                 kind: .inner)
    } else {
      return nil
    }
  }

  private var info: String {

    var info = ""

    func addInfo(_ title: String, _ vc: UIViewController?) {
      guard let vc else { return }
      info += "**\(title)**\n\(vc.description)\n\n"
    }

    addInfo("Presenting", presentingViewController)
    addInfo("Presented", presentedViewController)
    addInfo("Parent", parent)
    addInfo("Navigation Parent", navigationController?.parent)

    return info
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

