//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
import Foundation

public struct ScreenEvent: CustomStringConvertible, Codable {
  public let screenStaticID: ScreenStaticID
  public let id: ScreenID
  public let kind: Kind

  public enum Kind: Codable, CustomStringConvertible {
    case didAppear(detached: Bool, appearance: ScreenAppearance)
    case didDisappear
    case route(ScreenStaticID, RouteKind)
    
    public var description: String {
      switch self {
      case let .didAppear(detached, appearance):
        return "appeared \(appearance.appearance.description)" + (detached ? " (detached)" : "")
      case .didDisappear:
        return "disappeared"
      case let .route(screeID, kind):
        switch kind {
        case .sheet:
          return "willSheet \(screeID)"
        case .fullscreen:
          return "willFullscreen \(screeID)"
        case .push:
          return "willPush \(screeID)"
        }
      }
    }
  }

  public init(id: ScreenID, staticID: ScreenStaticID, kind: Kind) {
    self.screenStaticID = staticID
    self.kind = kind
    self.id = id
  }

  public var description: String {
    "Screen \(screenStaticID.type)[\(id)] \(kind)"
  }
}
