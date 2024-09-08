//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ScreenAction: Hashable, Codable, CustomStringConvertible {
  public typealias Params = [String: String]

  let rawValue: String
  public init(_ rawValue: String) {
    self.rawValue = rawValue.lowercased()
  }

  public static let fullscreen = Self("fullscreen")
  public static let sheet = Self("sheet")
  public static let push = Self("push")
  public static let dismiss = Self("dismiss")
  public static let popToRoot = Self("poptoroot")

  public var description: String { rawValue }
}

