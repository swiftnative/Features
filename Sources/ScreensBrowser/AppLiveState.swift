//
// Created by Alexey Nenastyev on 15.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI

public struct AppLiveState: Codable {
  public var screens: [ScreenControllerInfo]
  public let viewControllers: [Tree<ViewController>]
  public var current: ScreenID?

  public init(screens: [ScreenControllerInfo],
              viewControllers: [Tree<ViewController>],
              current: ScreenID?) {
    self.screens = screens
    self.viewControllers = viewControllers
    self.current = current
  }
}
