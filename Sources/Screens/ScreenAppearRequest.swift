//
//  File.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//
import Foundation
import SwiftUI

public struct ScreenAppearRequest: Hashable, Identifiable {

  public typealias RequestID = UInt

  private static var counter: RequestID = 1

  let screenStaticID: ScreenStaticID
  let view: AnyView

  let requestID: RequestID = {
    let value = Self.counter
    Self.counter += 1
    return value
  }()

  public var id: RequestID { requestID }

  public struct Kind: Hashable, Codable, CustomStringConvertible {
    public var description: String { rawValue }

    public let rawValue: String

    public static let fullscreen: Self = .init(rawValue: "fullscreen")
    public static let sheet: Self = .init(rawValue: "sheet")
    public static let push: Self = .init(rawValue: "push")
  }

  public static func == (lhs: ScreenAppearRequest, rhs: ScreenAppearRequest) -> Bool {
    lhs.requestID == rhs.requestID
  }

  public func hash(into hasher: inout Hasher) {
      hasher.combine(requestID)
  }

}
