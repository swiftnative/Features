//
// Created by Alexey Nenastyev on 5.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import ScreensUI
import Combine

@Screen(alias: "Tab")
struct TabScreen {

  var screenBody: some View {

    TabView() {

      TestScreenStackWrapped()
      .tabItem {
        Label("Inner Stack", systemImage: "books.vertical")
      }

      TestNestedScreenStackWrapped()
        .tabItem {
          Label("Nested Screen", systemImage: "pip")
        }
        .accessibilityIdentifier("Use Cases")

      UseCasesScreen()
        .tabItem {
          Label("Inner Tabs", systemImage: "book.pages")
        }
        .accessibilityIdentifier("Inner Tabs")

      NavigationView {
        SettingsView()
      }
      .tabItem {
        Label("Wrapped Navigation", systemImage: "gear")
      }
    }
    .accessibilityIdentifier("Tab Bar")
  }
}

#Preview {
  TabScreen()
    .environmentObject(MyMusicApp())
}
