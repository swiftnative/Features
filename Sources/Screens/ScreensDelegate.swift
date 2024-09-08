//
// Created by Alexey Nenastyev on 5.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os
import UIKit
import ScreensBrowser
import SwiftUI

/// Global delegate for all features
public protocol ScreensDelegate {

  var screens: [any Screen.Type] { get }

  func open(url: ScreenURL)
  func didFailToOpen(url: ScreenURL, error: Error)

  func action<S: Screen>(_ action: ScreenAction, screen: S, params: ScreenAction.Params?)

  func event(event: ScreenEvent)
}

public extension ScreensDelegate {

  var `default`: ScreensDelegate { Screens.shared }

  var screens: [any Screen.Type] { [] }

  func event(event: ScreenEvent) {}

  func open(url open: ScreenURL) {
    if open.path == nil || open.path == EmptyScreen.path {
      open(by: EmptyScreen.self)
      return
    }

    guard let screen = screens.first(where: {
      ($0 as? any ScreenURLDecodable.Type)?.path == open.path
    }), let decodableScreen = screen as? any ScreenURLDecodable.Type else { return }

    open(by: decodableScreen)
  }


  func didFailToOpen(url: ScreenURL, error: any Error) {
    print("Failed to open: \(url), error: \(error)")
  }

  func action<S: Screen>(_ action: ScreenAction, screen: S, params: ScreenAction.Params?) {
    switch action {
    case .fullscreen:
      Screens.current.fullscreen(screen)
    case .push:
      Screens.current.push(screen)
    case .sheet:
      Screens.current.sheet(screen)
    case .dismiss:
      Screens.current.dismiss()
    case .popToRoot:
      Screens.current.popToRoot()
    case .close:
      Screens.current.close()
    default:
      print("Unknown screen action: \(action)")
      break
    }
  }
}
