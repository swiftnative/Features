//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation

public enum BrowserMessage {

  public enum To: Codable, CustomDebugStringConvertible {
    case application(AppInfo)
    case screenShoot(ScreenShoot)
    case screen(ScreenLiveInfo)
    case appLiveState(AppLiveState)
    case screensStaticInfo([ScreenStaticInfo])
    case screenURLError(ScreenURL, String)
    case error(String)
    case screenEvent(ScreenEvent)

    public var debugDescription: String {
      switch self {
      case .application: "application info"
      case .appLiveState: "app state update"
      case .screenShoot: "screenShoot"
      case .screen: "screen"
      case .screensStaticInfo: "screensStaticInfo"
      case .screenEvent(let event): event.description
      case let .error(error): "Error: \(error)"
      case let .screenURLError(url, error): "Failed to open \(url). Error: \(error)"
      }
    }
  }

  public enum From: Codable, CustomDebugStringConvertible {
    case sendAppication
    case sendAppState
    case sendScreenInfo(ScreenID)
    case sendAllScreens
    case dismiss(ScreenID)
    case screenURL(ScreenURL)

    public var debugDescription: String {
      switch self {
      case let .screenURL(url): "Open \(url)"
      case let .sendScreenInfo(nodeID): "sendScreenInfo \(nodeID)"
      case .dismiss(let id): "dismiss \(id)"
      case .sendAppication: "sendAppication"
      case .sendAppState: "sendAppState"
      case .sendAllScreens: "sendAllScreens"
      }
    }
  }
}
