//
//  ViewURLApp.swift
//  ViewURL
//
//  Created by Alexey Nenastev on 5.7.24..
//
import SwiftUI
import Observation
@_exported import ScreensUI

@main
struct DemoApp: App {
  @StateObject var browser = BrowserProxy(config: .local)

  var body: some Scene {
    WindowGroup {
      Tests()
        .onAppear {
          Screens.browser = browser
          browser.connect()
          Screens.delegate = self
        }
        .environmentObject(browser)
    }
  }
}
