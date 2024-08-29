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
      LibraryView()
        .tabItem {
          Label("Library", systemImage: "books.vertical")
        }

      ScreenStack {
        UseCasesScreen()
      }
      .tabItem {
        Label("Use Cases", systemImage: "scribble.variable")
      }
      .accessibilityIdentifier("Use Cases")

      MyMusicView()
        .tabItem {
          Label("MyMusic", systemImage: "music.note")
        }

      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
    .accessibilityIdentifier("Tab Bar")
  }
}

#Preview {
  TabScreen()
    .environmentObject(MyMusicApp())
}
