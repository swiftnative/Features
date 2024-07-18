//
// Created by Alexey Nenastyev on 5.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

@Feature
struct HomeView {

  var featureBody: some View {
    TabView() {
      FeaturesView()
        .tabItem {
          Label("Features", systemImage: "umbrella")
        }

      StarView()
        .tabItem {
          Label("Second", systemImage: "star")
        }

      FeatureBrowserView()
        .tabItem {
          Label("TV", systemImage: "tv.badge.wifi")
        }
    }
  }
}

#Preview {
  HomeView()
}
