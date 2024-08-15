//
// Created by Alexey Nenastyev on 4.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public extension Screens {
  static func open(url: ScreenURL) {
    delegate.open(url: url)
  }

  static func open(url: URL) {
    guard let screenURL = ScreenURL(url: url) else { return }
    open(url: screenURL)
  }

  static func action<S: Screen>(_ action: ScreenAction, screen: S, params: ScreenAction.Params? = nil) {
    delegate.action(action, screen: screen, params: params)
  }
}
