//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ScreenLiveInfo: Hashable, Codable {
  public let staticID: ScreenStaticID
  public let screenID: ScreenID
  public let tag: String?
  public let children: [ScreenID]
  public let size: ScreeSize
  public let parentScreenID: ScreenID?
  public let state: ScreenState
  public let stack: NavigationStackInfo?
  public let info: String
  public var type: String { staticID.type }
  public var file: String { staticID.file }
  public var environment: EnvironmentInfo?
  public var preferences: PreferencesInfo?
  public let alias: String?
  public let hasParentVC: Bool


  public init(screenID: ScreenID,
              staticID: ScreenStaticID,
              alias: String?,
              tag: String?,
              parentScreenID: ScreenID?,
              hasParentVC: Bool = true,
              state: ScreenState,
              size: ScreeSize,
              stack: NavigationStackInfo?,
              children: [ScreenID] = [],
              environment: EnvironmentInfo? = nil,
              preferences: PreferencesInfo? = nil,
              info: String) {
    self.screenID = screenID
    self.staticID = staticID
    self.hasParentVC = hasParentVC
    self.alias = alias
    self.tag = tag
    self.parentScreenID = parentScreenID
    self.state = state
    self.size = size
    self.stack = stack
    self.info = info
    self.children = children
    self.environment = environment
    self.preferences = preferences
  }
}

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

public struct NavigationStackInfo: Codable, Hashable {
  public let stackID: ViewController.ID
  public let index: Int
  public let kind: StackKind

  public init(stackID: ViewController.ID, index: Int, kind: StackKind) {
    self.stackID = stackID
    self.index = index
    self.kind = kind
  }
}

public enum StackKind: String, Codable {
  case inner
  case outer
}

public struct EnvironmentInfo: Codable, Hashable {
  public let isPresented: Bool

  public init(isPresented: Bool) {
    self.isPresented = isPresented
  }
}


public struct PreferencesInfo: Codable, Hashable {
  public let innerNaigationDestination: Bool

  public init(innerNaigationDestination: Bool) {
    self.innerNaigationDestination = innerNaigationDestination
  }
}
