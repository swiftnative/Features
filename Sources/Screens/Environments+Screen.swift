//
//  ScreenAdressKey.swift
//  Screens
//
//  Created by Alexey Nenastev on 5.9.24..
//
import SwiftUI


struct ScreenAdressKey : EnvironmentKey {
  static var defaultValue: Int = .zero
}

struct ScreenIDKey : EnvironmentKey {
  static var defaultValue: ScreenID = .zero
}

struct ScreenKey : EnvironmentKey {
  static var defaultValue: ScreenInfo = .empty
}

struct DetachedScreen : EnvironmentKey {
  static var defaultValue: Bool = false
}

extension EnvironmentValues {
  public  var screenID: ScreenID {
    get { self[ScreenIDKey.self] }
    set { self[ScreenIDKey.self] = newValue }
  }

  public  var screen: ScreenInfo {
    get { self[ScreenKey.self] }
    set { self[ScreenKey.self] = newValue }
  }

  var screenAddress: Int {
    get { self[ScreenAdressKey.self] }
    set { self[ScreenAdressKey.self] = newValue }
  }

  var detachedScreen: Bool {
    get { self[DetachedScreen.self] }
    set { self[DetachedScreen.self] = newValue }
  }
}


public struct ScreenInfo: CustomStringConvertible {
  public let id: ScreenID
  public let type: String

  public var description: String {
    "\(type)[\(id)]"
  }

  public static var empty = ScreenInfo(id: 0, type: "")
}

public extension View {
  // Use this propery to say that screen viewcontroller will not be attached to view controllers hierarhy
  // One of usecase for those screens: TabView with page style
  var screenDetached: some View {
    environment(\.detachedScreen, true)
  }
}
