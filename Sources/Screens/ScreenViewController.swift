//
//  ScreenViewController.swift
//  Screens
//
//  Created by Alexey Nenastev on 5.9.24..
//
import UIKit
import os

final class ScreenViewController: UIViewController {

  let screenID: ScreenID
  let staticID: ScreenStaticID
  var logID: String { "\(staticID.type)[\(screenID)]" }
  var detached: Bool { parent == nil }
  var notifiedWillPoppedBack = false
  override var description: String { "\(logID)-\(vcID.pointer)" }
  override var debugDescription: String { "\(logID)-\(vcID.pointer)" }


  weak var delegate: ScreenViewControllerDelegate?

  init(id: ScreenID, staticID: ScreenStaticID) {
    self.screenID = id
    self.staticID = staticID
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    Logger.uikit.log("\(self.logID) vc deinit \(self.address.pointer)")
  }

  var innerNC: UINavigationController? {
    parent?.children.first { $0 is UINavigationController } as? UINavigationController
  }
  var outerNC: UINavigationController? {
    navigationController
  }
  var rootNC: UINavigationController? {
    navigationController?.navigationController
  }

  var indexInOuterNC: Int? { outerNC?.index(of: self) }
  var indexInInnerNC: Int? { innerNC?.index(of: self) }
  var indexInRootNC: Int? { rootNC?.index(of: self) }

  var isTabBar: Bool {
    parent?.children.first { $0 is UITabBarController } != nil
  }

  override func viewDidLoad() {
    Logger.uikit.log("\(self.logID) viewDidLoad")
    delegate?.viewDidLoad()
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    Logger.uikit.log("\(self.logID) viewWillAppear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)] ")
   delegate?.viewWillAppear(animated)
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    Logger.uikit.log("\(self.logID) viewWillDisappear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    delegate?.viewWillDisappear(animated)
    super.viewWillDisappear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    Logger.uikit.log("\(self.logID) viewDidAppear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    delegate?.viewDidAppear(animated)
    super.viewDidAppear(animated)
  }

  override func viewDidDisappear(_ animated: Bool) {
    Logger.uikit.debug("\(self.logID) viewDidDisappear [p:\(self.isBeingPresented) d:\(self.isBeingDismissed) mtp:\(self.isMovingToParent) mfp:\(self.isMovingFromParent)]")
    delegate?.viewDidDisappear(animated)
    super.viewDidDisappear(animated)
  }

  override func didMove(toParent parent: UIViewController?) {
    Logger.uikit.log("\(self.logID) didMove to:\(parent)")
    super.didMove(toParent: parent)
  }

  override func willMove(toParent parent: UIViewController?) {
    Logger.uikit.log("\(self.logID) willMove to:\(parent)")
    super.willMove(toParent: parent)
  }
}
