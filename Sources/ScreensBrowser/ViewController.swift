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
    hasher.combine(screen)
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
  public let screen: Screen?
  public let address: Int
  public let parentID: ID?
  public let childs: [ID]
  public let info: [String: String]
  public let kind: Kind?
  public let stackID: ID?
  public let presentingID: ID?
  public let presentedID: ID?
  public let tabBarID: ID?

  public struct Screen: Codable, Hashable {
    public let id: ScreenID
    public let staticID: ScreenStaticID
    public var address: Int?
    public var outerNC: Int?
    public var innerNC: Int?
    public var rootNC: Int?
    public var indexInOuterNC: Int?
    public var indexInInnerNC: Int?
    public var indexInRootNC: Int?

    public init(id: ScreenID, staticID: ScreenStaticID) {
      self.id = id
      self.staticID = staticID
    }
  }

  public var isScreenController: Bool { screen != nil }

  public init(id: ID,
              type: String,
              screen: Screen? = nil,
              address: Int,
              parentID: ID? = nil,
              childs: [ID] = [],
              kind: Kind?,
              info: [String: String] = [:],
              stackID: ID? = nil,
              presentingID: ID? = nil,
              presentedID: ID? = nil,
              tabBarID: ID? = nil) {
    self.id = id
    self.type = type
    self.screen = screen
    self.address = address
    self.parentID = parentID
    self.info = info
    self.kind = kind
    self.childs = childs
    self.stackID = stackID
    self.presentingID = presentingID
    self.presentedID = presentedID
    self.tabBarID =  tabBarID
  }
}

extension ViewController: CustomDebugStringConvertible {
  public var debugDescription: String {
    if let screen {
      return "\(screen.staticID.type)[\(screen.id)]"
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
