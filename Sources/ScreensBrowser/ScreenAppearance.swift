//
//  ScreenAppearance.swift
//  Screens
//
//  Created by Alexey Nenastev on 27.8.24..
//
import SwiftUI

public struct ScreenAppearance: Codable, Hashable, CustomStringConvertible {

  public var appearance: Appearance = .dissapeared
  public var isFirstAppearance: Bool { count == 0 }
  public var count: Int = 0 
  public var firstAppearance: Appearance = .dissapeared
  public var lastAppearAt: CFAbsoluteTime = 0

  public enum Appearance: Codable, CustomStringConvertible {
    case popped
    case other
    case pushed
    case sheet
    case fullscreen
    case dissapeared

    public var description: String {
      switch self {
      case .popped: return "popped"
      case .other: return "other"
      case .pushed: return "pushed"
      case .sheet: return "sheet"
      case .fullscreen: return "fullscreen"
      case .dissapeared: return "dissapeared"
      }
    }
  }
  
  public var description: String {
    appearance.description + ( isFirstAppearance ? " firstTime" : "")
  }

  public init() {}
}
