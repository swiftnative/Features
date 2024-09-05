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

      ScreenStack {
        LibraryView()
      }
      .tabItem {
        Label("Library", systemImage: "books.vertical")
      }
      
      UseCasesScreen()
        .tabItem {
          Label("Use Cases", systemImage: "scribble.variable")
        }
        .accessibilityIdentifier("Use Cases")

      MyMusicView()
        .tabItem {
          Label("MyMusic", systemImage: "music.note")
        }

      NavigationView {
        SettingsView()
      }
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
