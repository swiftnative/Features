//
//  UIViewController+.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import ScreensBrowser
import SwiftUI

extension UINavigationController {
  func index(of vc: UIViewController) -> Int? {
    if vc.parent == self {
      return viewControllers.firstIndex(of: vc)
    } else if let parent = vc.parent {
      return index(of: parent)
    } else {
      return nil
    }
  }
}

extension UIViewController {

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

  var firstTabBarController: UITabBarController? {

    func scan(uiVC: UIViewController) -> UITabBarController? {
      if let tbc = uiVC as? UITabBarController {
        return tbc
      } else {
        for child in uiVC.children {
          guard let tbc = scan(uiVC: child) else { continue }
          return tbc
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
    if let tabBarController {
      info["tabBarController"] = tabBarController.vcID.pointer
    }
    if let navigationController {
      info["navigationController"] = navigationController.vcID.pointer
      info["index"] = navigationController.index(of: self)?.description ?? ""
    }

    if let vc = self as? UITabBarController {
      info["TBC.selectedIndex"] = vc.selectedIndex.description
      info["TBC.delegate"] = vc.delegate.debugDescription
    } else if let vc = self as? UINavigationController {
      info["NC.isNavigationBarHidden"] = vc.isNavigationBarHidden.description
      info["NC.delegate"] = vc.delegate.debugDescription
      info["NC.visibleViewController"] = vc.visibleViewController?.vcID.pointer
      info["NC.topViewController"] = vc.topViewController?.vcID.pointer
    }

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
                          presentedID: presentedViewController?.vcID)
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

extension Int {
  var pointer: String {
    String(format:"%p", self)
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
