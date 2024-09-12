//
//  File.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//
import Foundation
import SwiftUI

public struct ScreenRouteRequest: Hashable, Identifiable, CustomDebugStringConvertible {

  public typealias RequestID = UInt

  private static var counter: RequestID = 1

  public let screenStaticID: ScreenStaticID
  public let view: AnyView
  public var animation: Bool = false
  var kind: RouteKind

  let requestID: RequestID = {
    let value = Self.counter
    Self.counter += 1
    return value
  }()

  public var id: RequestID { requestID }

  public init(screenStaticID: ScreenStaticID, view: AnyView, kind: RouteKind) {
    self.screenStaticID = screenStaticID
    self.view = view
    self.kind = kind
  }
  
  public struct Kind: Hashable, Codable, CustomStringConvertible {
    public var description: String { rawValue }

    public let rawValue: String

    public static let fullscreen: Self = .init(rawValue: "fullscreen")
    public static let sheet: Self = .init(rawValue: "sheet")
    public static let push: Self = .init(rawValue: "push")
  }

  public static func == (lhs: ScreenRouteRequest, rhs: ScreenRouteRequest) -> Bool {
    lhs.requestID == rhs.requestID
  }

  public func hash(into hasher: inout Hasher) {
      hasher.combine(requestID)
  }

  public var debugDescription: String {
    "\(id)-\(screenStaticID)"
  }

}
