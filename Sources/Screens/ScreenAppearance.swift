//
//  ScreenAppearance.swift
//  Screens
//
//  Created by Alexey Nenastev on 27.8.24..
//
import SwiftUI

public struct ScreenAppearance: CustomStringConvertible {

  public var appearance: Appearance = .other
  public var isFirstAppearance: Bool { count < 2 }
  public var count: Int = 0
  public var firstAppearance: Appearance = .other

  public enum Appearance: CustomStringConvertible {
    case poppedTo
    case other
    case pushed
    case sheet
    case fullscreen

    public var description: String {
      switch self {
      case .poppedTo: return "poppedTo"
      case .other: return "other"
      case .pushed: return "pushed"
      case .sheet: return "sheet"
      case .fullscreen: return "fullscreen"
      }
    }
  }
  
  public var description: String {
    appearance.description + ( isFirstAppearance ? " firstTime" : "")
  }
}
