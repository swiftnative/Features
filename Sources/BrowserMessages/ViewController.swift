//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation

public final class ViewController: Codable, Hashable {

  public static func == (lhs: ViewController, rhs: ViewController) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(type)
    hasher.combine(screenID)
    hasher.combine(address)
    hasher.combine(parentID)
  }

  public enum Kind: String, Codable {
    case nc
    case tb
  }

  public typealias ID = Int
  public let id: ID
  public let type: String
  public let screenType: String?
  public let screenID: ScreenID?
  public let address: Int
  public let parentID: ID?
  public let childs: [ID]
  public let controllers: [ID]
  public let info: [String: String]
  public let kind: Kind?
  public let stackID: ID?
  public let presentingID: ID?
  public let presentedID: ID?
  

  public var isScreenController: Bool { screenID != nil }

  public init(id: ID,
              type: String,
              screenID: ScreenID? = nil,
              screenType: String? = nil,
              address: Int,
              parentID: ID? = nil,
              childs: [ID] = [],
              controllers: [ID] = [],
              kind: Kind?,
              info: [String: String] = [:],
              stackID: ID? = nil,
              presentingID: ID? = nil,
              presentedID: ID? = nil
  ) {
    self.id = id
    self.type = type
    self.screenID = screenID
    self.address = address
    self.parentID = parentID
    self.info = info
    self.kind = kind
    self.childs = childs
    self.controllers = controllers
    self.stackID = stackID
    self.presentingID = presentingID
    self.presentedID = presentedID
    self.screenType = screenType
  }
}

extension ViewController: CustomDebugStringConvertible {
  public var debugDescription: String {
    if let screenType, let screenID {
      return "\(screenType)-\(screenID.uuidString.prefix(5))"
    } else {
      return type
    }
  }
}

public extension ViewController {
  static var root = ViewController(id: 0,
                                   type: "Root",
                                   address: 0,
                                   parentID: nil,
                                   kind: nil)
}
