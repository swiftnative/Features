//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
import Foundation

public struct ScreenEvent: CustomStringConvertible, Codable {
  let screenStaticID: ScreenStaticID
  let id: ScreenID
  let kind: Kind

  public enum Kind: Codable, CustomStringConvertible {
    case didAppear
    case didDisappear
    case willSheet(ScreenStaticID)
    case willFullscreen(ScreenStaticID)
    case willPush(ScreenStaticID)

    public var description: String {
      switch self {
      case .didAppear:
        return "didAppear"
      case .didDisappear:
        return "didDisappear"
      case .willSheet(let screeID):
        return "willSheet \(screeID)"
      case .willFullscreen(let screeID):
        return "willFullscreen \(screeID)"
      case .willPush(let screeID):
        return "willPush \(screeID)"
      }
    }
  }

  public init(id: ScreenID, staticID: ScreenStaticID, kind: Kind) {
    self.screenStaticID = staticID
    self.kind = kind
    self.id = id
  }

  public var description: String {
    "Screen \(screenStaticID.type)-\(id) \(kind)"
  }
}
