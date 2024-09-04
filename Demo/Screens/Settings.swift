//
// Created by Alexey Nenastyev on 7.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import ScreensUI

@Screen(alias: "Settings")
struct SettingsView: View {

  var screenBody: some View {
      VStack {
        ConnectionView()
        List {
          Button("Theme") {
            Screens.current.push(ChoseThemeScreen())
          }
        }
      }
  }
}



struct ConnectionView : View {
  @EnvironmentObject var proxy: BrowserProxy

  var body: some View {
    HStack {
      if proxy.isConnected {
        Text("Connected")
        Spacer()
        Button("Disconnect") {
          proxy.disconnect()
        }
      } else {
        Text("Disconnected")
        Spacer()
        Button("Connect") {
          proxy.connect()
        }
      }
    }
    .padding()
    .buttonStyle(.borderedProminent)
  }
}

#Preview {
  SettingsView()
}
