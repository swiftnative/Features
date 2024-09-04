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

  private func log(error message: String) {
    Logger.screens.error("[\(self.logID)] \(message)")
    Screens.shared.screen(error: "[\(self.logID)] \(message)")
  }

  public func push<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    Logger.screens.debug("[\(self.logID)] will push \(S.self)")
    Screens.shared.screen(kind: .willPush(S.screenID), for: self)

    let view = AnyView(screen.modifier(modifier))
    let request = ScreenAppearRequest(screenStaticID: S.screenID, view: view)

    if navigationController != nil  {
      pushOuter = request
    } else if let parentScreen, detached, parentScreen.navigationController != nil || parentScreen.hasNavigationDestination {
      pushOuter = request
    } else if hasNavigationDestination {
      pushNavigationDestination = request
    } else {
      Logger.screens.error("[\(self.logID)] can't push \(S.self), no navigation controller")
    }
  }

  public func fullscreen<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    Screens.shared.screen(kind: .willFullscreen(S.screenID), for: self)
    let view = AnyView(screen.modifier(modifier))
    self.fullcreen = ScreenAppearRequest(screenStaticID: S.screenID, view: view)
  }

  public func sheet<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier  {
    Screens.shared.screen(kind: .willSheet(S.screenID), for: self)
    let view = AnyView(screen.modifier(modifier))
    self.sheet = ScreenAppearRequest(screenStaticID: S.screenID, view: view)
  }

  public func sheet<S, M1, M2>(_ screen: S, modifier: M1, _ modifier2: M2) where S : Screen, M1 : ViewModifier, M2: ViewModifier  {
    Screens.shared.screen(kind: .willSheet(S.screenID), for: self)
    let view = AnyView(screen
      .modifier(modifier)
      .modifier(modifier2)
    )
    self.sheet = ScreenAppearRequest(screenStaticID: S.screenID, view: view)
  }

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
