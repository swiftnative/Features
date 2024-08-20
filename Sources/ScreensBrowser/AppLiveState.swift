//
// Created by Alexey Nenastyev on 15.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI

public struct AppLiveState: Codable {
  public var screens: [ScreenLiveInfo]
  public let currentFeatureNodeID: ViewController.ID?
  public let currentStackID: ViewController.ID?
  public let tree: [Tree<ViewController>]
  public var current: ScreenID?

  public init(screens: [ScreenLiveInfo],
              current: ScreenID?,
              currentFeatureNodeID: ViewController.ID? = nil,
              currentStackID: ViewController.ID? = nil,
              tree: [Tree<ViewController>] = []
  ) {
    self.screens = screens
    self.currentFeatureNodeID = currentFeatureNodeID
    self.currentStackID = currentStackID
    self.tree = tree
    self.current = current
  }
}
