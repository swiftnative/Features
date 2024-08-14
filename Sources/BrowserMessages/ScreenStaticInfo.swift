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
}

public struct ScreenStaticID: Hashable, Codable {
  public let type: String
  public let file: String

  public init(type: String, file: StaticString = #file) {
    self.type = type
    self.file = "\(file)"
  }
}

