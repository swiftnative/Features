//
//  ContentView.swift
//  Features
//
//  Created by Alexey Nenastev on 3.7.24..
//

import SwiftUI
import ModuleA
import ModuleB
import ModuleC
import Features

@Screen
struct ContentView: View {
  var screenBody: some View {

    TabView {
      NavigationView {
        FeatureA()
      }
      .tabItem {
        Label("", systemImage: "a.square")
      }

      NavigationView {
        FeatureB()
      }
      .tabItem {
        Label("", systemImage: "b.square")
      }

      NavigationView {
        FeatureC()
      }
      .tabItem {
        Label("", systemImage: "c.square")
      }
    }
  }
}

#Preview {
  ContentView()
}
