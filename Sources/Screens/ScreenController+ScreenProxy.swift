//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation
import SwiftUI
import ScreensBrowser

extension ScreenController: ScreenProxy {

  private func log(error message: String) {
    logger.error("[\(self.logID)] \(message)")
    screens.screen(error: "[\(self.logID)] \(message)")
  }

  public func push<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    logger.debug("[\(self.logID)] will push \(S.self)")
    screens.screen(kind: .willPush(S.screenID), for: self)

    let view = AnyView(screen.modifier(modifier))
    let request = ScreenAppearRequest(screenStaticID: S.screenID, view: view)

    if hasNavigationDestination {
//      pushNavigationDestination = nil
      pushNavigationDestination = request
      return
    } else {
//      pushOuter = nil
      pushOuter = request
      return
    }

    /// todo
//    if hasNavigationDestination && innerNC != nil {
//      pushNavigationDestination = request
//      return
//    }
//
//    if hasNavigationDestination && outerNC != nil {
//      log(error: "Has NavigationDestination, but no inner stack. Will try to push to the outer \(S.self).")
//      pushOuter = request
//      return
//    }
//
//    if outerNC != nil {
//      pushOuter = request
//      return
//    }
//
//    if innerNC != nil {
//      log(error: "No NavigationDestination, but has inner stack. Will try to push \(S.self).")
//      pushNavigationDestination = request
//      return
//    }
//
//    log(error:  "Cannot push screen \(S.self). No stack .")

  }

  public func fullscreen<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    screens.screen(kind: .willFullscreen(S.screenID), for: self)
    let view = AnyView(screen.modifier(modifier))
    self.fullcreen = ScreenAppearRequest(screenStaticID: S.screenID, view: view)
  }

  public func sheet<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier  {
    screens.screen(kind: .willSheet(S.screenID), for: self)
    let view = AnyView(screen.modifier(modifier))
    self.sheet = ScreenAppearRequest(screenStaticID: S.screenID, view: view)
  }

  public func sheet<S, M1, M2>(_ screen: S, modifier: M1, _ modifier2: M2) where S : Screen, M1 : ViewModifier, M2: ViewModifier  {
    screens.screen(kind: .willSheet(S.screenID), for: self)
    let view = AnyView(screen
      .modifier(modifier)
      .modifier(modifier2)
    )
    self.sheet = ScreenAppearRequest(screenStaticID: S.screenID, view: view)
  }

  public var stack: StackProxy? {
    stackInfo
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
