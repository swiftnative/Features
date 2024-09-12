//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import ScreensUI

extension DemoApp: ScreensDelegate {

  var screens: [any Screen.Type] {
    [Dog.self,
     Cat.self]
  }


  func action<S: Screen>(_ action: ScreenAction, screen: S, params: ScreenAction.Params?) {
    switch action {
    case .fullscreen:
      Screens.current.fullscreen(screen, modifier: .closeButton)
    case .sheet:
      if #available(iOS 16.0, *) {
        Screens.current.sheet(screen, modifiers: .detents(.medium, .large), .closeButton)
      } else {
        Screens.current.sheet(screen, modifier: .closeButton)
      }
    default:
      self.default.action(action, screen: screen, params: params)
    }
  }
}
