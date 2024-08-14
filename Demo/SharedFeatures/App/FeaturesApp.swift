//
//  FeaturesApp.swift
//  Features
//
//  Created by Alexey Nenastev on 3.7.24..
//

import SwiftUI
import Features

@main
struct FeaturesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
              Screens.shared.connect()
            }
        }
    }
}
