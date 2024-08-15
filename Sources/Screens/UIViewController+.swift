//
//  UIViewController+.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import BrowserMessages
import SwiftUI

extension UIViewController {

  var outerNC: UINavigationController? {
    navigationController
  }

  var innerNC: UINavigationController? {
    parent?.firstNavigationController
  }

  var rootParent: UIViewController? {

    func scan(uiVC: UIViewController) -> UIViewController? {
      if let parent = uiVC.parent {
        return scan(uiVC: parent)
      } else {
        return uiVC
      }
    }

    return scan(uiVC: self)
  }

  var firstNavigationController: UINavigationController? {

    func scan(uiVC: UIViewController) -> UINavigationController? {
      if let nc = uiVC.navigationController ?? uiVC as? UINavigationController {
        return nc
      } else {
        for child in uiVC.children {
          guard let nc = scan(uiVC: child) else { continue }
          return nc
        }
      }
      return nil
    }

    return scan(uiVC: self)
  }

  var nodeDescription: String {
    var info: String = "**\(address)**\n"
    if let current = self as? ScreenController {
      info += current.nodeDebugName
    } else {
      info += vcType
    }
    return info
  }

  var address: Int {
    Int(bitPattern: Unmanaged.passUnretained(self).toOpaque())
  }

  var vcType: String {
    Swift.type(of: self).description()
  }

  var vcID: ViewController.ID {
    address
  }

  @MainActor
  var vc: ViewController {
    let scontroller = self as? ScreenController
    var controllers: [ViewController.ID] = []
    if let nc = self as? UINavigationController {
      controllers = nc.viewControllers.map { $0.vcID }
    }

    var info: [String: String] = [:]
    info["isViewLoaded"] = isViewLoaded.description
    info["isModalInPresentation"] = isModalInPresentation.description
    info["isFirstResponder"] = isFirstResponder.description
    info["isMovingToParent"] = isMovingToParent.description
    info["isMovingFromParent"] = isMovingFromParent.description
    info["isBeingPresented"] = isBeingPresented.description

    return ViewController(id: vcID,
                          type: vcType,
                          screenID: scontroller?.id,
                          screenType: scontroller?.staticID.type,
                          address: address,
                          parentID: parent?.vcID,
                          childs: children.map { $0.vcID },
                          controllers: controllers,
                          kind: kind,
                          info: info,
                          stackID: navigationController?.vcID,
                          presentingID: presentingViewController?.vcID,
                          presentedID: presentedViewController?.vcID
    )
  }

  var kind: ViewController.Kind? {
    switch self {
    case is UITabBarController: return .tb
    case is UINavigationController: return .nc
    default: return nil
    }
  }

  var uuid: UUID {
    if let value = objc_getAssociatedObject(self, &uuidKey) as? UUID {
      return value
    } else {
      let newValue = UUID()
      objc_setAssociatedObject(self, &uuidKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return newValue
    }
  }
}

private var uuidKey: UInt8 = 0

extension Array where Element: UIViewController {

  var uniqRootParanets: [UIViewController] {
    var parentsVC: [UIViewController] = []

    for uiVC in self {
      guard let parent = uiVC.rootParent, !parentsVC.contains(parent) else { continue }
      parentsVC.append(parent)
    }

    return parentsVC
  }

}
