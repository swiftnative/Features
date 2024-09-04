//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ScreenLiveInfo: Hashable, Codable {
  public let staticID: ScreenStaticID
  public let screenID: ScreenID
  public let alias: String?
  public let parentScreenID: ScreenID?
  public let tag: String?
  public let hasParentVC: Bool
  public let hasNavigationDestination: Bool

  public let size: ScreeSize
  public let stack: StackProxy?
  public let appearance: ScreenAppearance
  public let isPresented: Bool
  public let info: String


  public var type: String { staticID.type }
  public var file: String { staticID.file }


  public init(screenID: ScreenID,
              staticID: ScreenStaticID,
              alias: String?,
              tag: String?,
              parentScreenID: ScreenID?,
              hasParentVC: Bool = true,
              hasNavigationDestination: Bool = false,
              size: ScreeSize,
              stack: StackProxy?,
              appearance: ScreenAppearance,
              isPresented: Bool,
              info: String) {
    self.screenID = screenID
    self.staticID = staticID
    self.hasParentVC = hasParentVC
    self.alias = alias
    self.tag = tag
    self.hasNavigationDestination = hasNavigationDestination
    self.parentScreenID = parentScreenID
    self.size = size
    self.stack = stack
    self.info = info
    self.appearance = appearance
    self.isPresented = isPresented
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
