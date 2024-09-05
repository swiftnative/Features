//
//  ScreenController+Browser.swift
//  Screens
//
//  Created by Alexey Nenastev on 5.9.24..
//
import UIKit
import ScreensBrowser

//MARK: ScreenBrowser+
extension ScreenController {

  var info: ScreenControllerInfo {
    ScreenControllerInfo(screenID: id,
                         staticID: staticID,
                         alias: alias,
                         tag: tag,
                         parentScreenID: parentScreenID,
                         hasParentVC: parentVC != nil,
                         hasNavigationDestination: hasNavigationDestination,
                         size: ScreeSize(size: viewController?.view.frame.size ?? .zero),
                         stack: stack,
                         appearance: appearance,
                         isPresented: isPresented,
                         vcID: viewController?.vcID,
                         address: address,
                         parentAddress: parentAddress)
  }

  func screenshot() {
    guard let parentVC else { return }
    UIGraphicsBeginImageContext(parentVC.view.frame.size)
    parentVC.view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let data = image?.jpegData(compressionQuality: 1) else { return }
    let screenShot = ScreenShoot(screenID: id, data: data)
    Screens.shared.screen(shot: screenShot)
  }
}