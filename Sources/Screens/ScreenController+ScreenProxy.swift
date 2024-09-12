//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation
import SwiftUI
import ScreensBrowser
import os

extension ScreenController: ScreenProxy {

  private func request<S, V>(_ route: RouteKind, for screen: S, with view: V) where S : Screen, V: View {
    let request = ScreenRouteRequest(screenStaticID: S.screenID, view: view.anyView, kind: route)
    router?.request(request)
  }

  public func push<S, M>(_ screen: S, modifier m1: M) where S : Screen, M : ViewModifier {
    let view = screen
      .modifier(m1)

    request(.push, for: screen, with: view)
  }

  public func fullscreen<S, M>(_ screen: S, modifier m1: M) where S : Screen, M : ViewModifier {
    let view = screen
      .modifier(m1)

    request(.fullscreen, for: screen, with: view)
  }

  public func fullscreen<S, M1, M2>(_ screen: S, modifier m1: M1, _ m2: M2) where S : Screen, M1 : ViewModifier, M2: ViewModifier {
    let view = screen
      .modifier(m1)
      .modifier(m2)

    request(.fullscreen, for: screen, with: view)
  }


  public func sheet<S, M>(_ screen: S, modifier m1: M) where S : Screen, M : ViewModifier  {
    let view = screen
      .modifier(m1)

    request(.sheet, for: screen, with: view)
  }

  public func sheet<S, M1, M2>(_ screen: S, modifiers m1: M1, _ m2: M2) where S : Screen, M1 : ViewModifier, M2: ViewModifier  {
    let view = screen
      .modifier(m1)
      .modifier(m2)

    request(.sheet, for: screen, with: view)
  }

  public func sheet<S, M1, M2, M3>(_ screen: S, modifiers m1: M1, _ m2: M2, _ m3: M3) where S : Screen, M1 : ViewModifier, M2: ViewModifier, M3: ViewModifier   {
    let view = screen
      .modifier(m1)
      .modifier(m2)
      .modifier(m3)

    request(.sheet, for: screen, with: view)
  }

  public func popToRoot() {
    if let rootNC {
      outerNC?.popToRootViewController(animated: false)
      rootNC.popToRootViewController(animated: true)
    } else if let outerNC {
      outerNC.popToRootViewController(animated: true)
    } else if let innerNC {
      innerNC.popToRootViewController(animated: true)
    } else {
      dismiss()
    }
  }

  public func close() {
    guard var topController = UIApplication.shared.firstKeyWindow?.rootViewController else { return }
    while let presentedViewController = topController.presentedViewController {
      topController = presentedViewController
    }
    topController.dismiss(animated: true)
  }
}

extension View {
  var anyView: AnyView { AnyView(self) }
}

public extension ViewModifier where Self == EmptyModifier {
  static var empty: Self { EmptyModifier() }
}

extension UIApplication {
  var firstKeyWindow: UIWindow? {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive }
      .first?.keyWindow

  }
}
