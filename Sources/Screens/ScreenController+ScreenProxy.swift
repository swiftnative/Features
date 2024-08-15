//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation
import SwiftUI

extension ScreenController: ScreenProxy {

  public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) {
    self.environment[keyPath: keyPath] = value
  }

  public func push<S>(_ screen: S) where S : Screen {
    guard let nc = outerNC ?? innerNC else { return }

    let rootView = screen

    let host = UIHostingController(rootView: rootView)
    nc.pushViewController(host, animated: true)
  }

  public func fullscreen<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    guard let parent else { return }

    let rootView = screen
      .modifier(modifier)
      .environment(\.screenID, id)
      .environment(\.self, environment)

    let vc = ScreensPresentationHostingController(rootView: rootView)
    vc.modalPresentationStyle = .fullScreen
    parent.present(vc, animated: true)

  }

  public func sheet<S, M>(_ screen: S, modifier: M, configurate: (UISheetPresentationController) -> Void) where S : Screen, M : ViewModifier  {
    guard let parent else { return }
    let rootView = screen
      .modifier(modifier)
      .environment(\.screenID, id)
      .environment(\.self, environment)

    let vc = ScreensPresentationHostingController(rootView: rootView)
    if let sheet = vc.sheetPresentationController {
      configurate(sheet)
    }
    logger.debug("[\(self.id)] sheet parent:\(parent.vcID) parent.isViewLoaded: \(parent.isViewLoaded)")
    DispatchQueue.main.async {
      parent.present(vc, animated: true)
    }
  }

  public func close() {
    self.dismiss(animated: true)
  }
}



extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow

    }
}
