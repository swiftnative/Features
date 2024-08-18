//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation
import SwiftUI
import BrowserMessages

extension ScreenController: ScreenProxy {

  public func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) {
    self.environment[keyPath: keyPath] = value
  }

  public func push<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    screens.screen(kind: .willPush(S.screenID), for: self)

    var stackKind: StackKind?

    if outerNC != nil {
      stackKind = .outer
    } else if innerNC != nil {
      stackKind = .inner
    }
    
    guard let stackKind else {
      logger.error("[\(self.logID)] Cannot push screen \(S.self). No stack .")
      screens.screen(error: "[\(self.logID)] Cannot push screen \(S.self). No stack .")
      return
    }

    if stackKind == .inner &&  hasInnerNavigationDestination == false  {
      logger.error("[\(self.logID)] Has inner stack, but no screenNavigationDestination. Cannot push screen \(S.self).")
      screens.screen(error: "[\(self.logID)] Has inner stack, but no screenNavigationDestination. Cannot push screen \(S.self).")
      return
    }

    let rootView = screen
      .modifier(modifier)

    Notification.PushScreenNotification.post(.init(screen: AnyView(rootView),
                                             kind: stackKind,
                                             stackHolder: id))
//    stack.pushViewController(UIHostingController(rootView: AnyView(rootView)), animated: true)
  }

  public func fullscreen<S, M>(_ screen: S, modifier: M) where S : Screen, M : ViewModifier {
    screens.screen(kind: .willFullscreen(S.screenID), for: self)

    guard let parent else {
      logger.error("[\(self.logID)] Cannot present fullscreen screen \(S.self). Parent view controller is nil.")
      screens.screen(error: "[\(self.logID)] Cannot present fullscreen screen \(S.self). Parent view controller is nil.")
      return
    }

    let rootView = screen
      .modifier(modifier)
      .environment(\.screenID, id)
      .environment(\.self, environment)

    let vc = ScreensPresentationHostingController(rootView: rootView)
    vc.modalPresentationStyle = .fullScreen
    parent.present(vc, animated: true)
  }

  public func sheet<S, M>(_ screen: S, modifier: M, configurate: (UISheetPresentationController) -> Void) where S : Screen, M : ViewModifier  {
    screens.screen(kind: .willSheet(S.screenID), for: self)

    guard let parent else {
      logger.error("[\(self.logID)] Cannot present sheet screen \(S.self). Parent view controller is nil.")
      screens.screen(error: "[\(self.logID)] Cannot present sheet screen \(S.self). Parent view controller is nil.")
      return
    }
    let rootView = screen
      .modifier(modifier)
      .environment(\.screenID, id)
      .environment(\.self, environment)

    let vc = ScreensPresentationHostingController(rootView: rootView)
    if let sheet = vc.sheetPresentationController {
      configurate(sheet)
    }
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
