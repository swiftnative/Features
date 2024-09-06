//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ScreenControllerInfo: Hashable, Codable {
  public let staticID: ScreenStaticID
  public let screenID: ScreenID
  public let alias: String?
  public let parentScreenID: ScreenID?
  public let tag: String?
  public let hasNavigationDestination: Bool
  public let size: ScreeSize
  public let stack: StackProxyInfo?
  public let appearance: ScreenAppearance?
  public let isPresented: Bool
  public let vcID: ViewController.ID?
  public let address: Int
  public let parentAddress: Int?

  public var isAppeared: Bool {
    guard let appearance else { return false }
    return appearance.appearance != .dissapeared
  }

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
              stack: StackProxyInfo?,
              appearance: ScreenAppearance?,
              isPresented: Bool,
              vcID: ViewController.ID?,
              address: Int,
              parentAddress: Int?) {
    self.screenID = screenID
    self.staticID = staticID
    self.alias = alias
    self.tag = tag
    self.hasNavigationDestination = hasNavigationDestination
    self.parentScreenID = parentScreenID
    self.size = size
    self.stack = stack
    self.appearance = appearance
    self.isPresented = isPresented
    self.vcID = vcID
    self.address = address
    self.parentAddress = parentAddress
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
