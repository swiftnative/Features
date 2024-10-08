//
// Created by Alexey Nenastyev on 5.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ScreenStaticInfo: Hashable, Codable, Identifiable {
  public var id: ScreenStaticID { staticID }
  public let staticID: ScreenStaticID
  public let alias: String?
  public let path: String?
  public let params: [String]?
  public let description: String

  public init(staticID: ScreenStaticID, alias: String?, path: String?, params: [String]?, description: String) {
    self.staticID = staticID
    self.alias = alias
    self.path = path
    self.params = params
    self.description = description
  }

  public var urlDecodable: Bool {
    path != nil
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct ScreenStaticID: Hashable, Codable, CustomStringConvertible {
  public let type: String
  public let file: String

  public var description: String {
    type
  }

  public init(type: String, file: StaticString = #file) {
    self.type = type
    self.file = "\(file)"
  }
}

