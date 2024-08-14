//
// Created by Alexey Nenastyev on 15.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI

public struct NodeStackInfo: Codable, Hashable {
  public let stackID: ViewController.ID
  public let index: Int

  public init(stackID: ViewController.ID, index: Int) {
    self.stackID = stackID
    self.index = index
  }
}

public typealias ScreenID = UUID

public struct ScreeSize: Codable, Hashable, CustomStringConvertible {
  public let width: Double
  public let height: Double

  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }

  public init(size: CGSize) {
    self.width = size.width
    self.height = size.height
  }

  public var description: String {
    "\(Int(width))x\(Int(height))"
  }
}

public struct ScreenLiveInfo: Hashable, Codable {
  public let staticID: ScreenStaticID
  public let screenID: ScreenID
  public let tag: String?
  public let children: [ScreenID]
  public let size: ScreeSize
  public let parentScreenID: ScreenID?
  public let state: ScreenState
  public let stack: NodeStackInfo?
  public let info: String
  public var type: String { staticID.type }
  public var file: String { staticID.file }

  public let alias: String?

  public init(screenID: ScreenID,
              staticID: ScreenStaticID,
              alias: String?,
              tag: String?,
              parentScreenID: ScreenID?,
              state: ScreenState,
              size: ScreeSize,
              stack: NodeStackInfo?,
              children: [ScreenID] = [],
              info: String) {
    self.screenID = screenID
    self.staticID = staticID
    self.alias = alias
    self.tag = tag
    self.parentScreenID = parentScreenID
    self.state = state
    self.size = size
    self.stack = stack
    self.info = info
    self.children = children
  }
}

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

public struct ScreenShoot: Codable {
  public let screenID: ScreenID
  public let data: Data

  public init(screenID: ScreenID, data: Data) {
    self.screenID = screenID
    self.data = data
  }
}


public extension UUID {
  static var zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}
