//
//  ViewURLApp.swift
//  ViewURL
//
//  Created by Alexey Nenastev on 5.7.24..
//

import SwiftUI
import Observation
import Features

@main
struct ViewURLApp: App {
  var body: some Scene {
    WindowGroup {
      HomeView()
      .onAppear {
        FeatureDelegate.logger = nil
        FeatureTree.shared.connect()
      }
      .buttonStyle(.borderedProminent)
    }

  }
}



