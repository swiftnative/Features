//
//  UseCasesScreen.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 25.8.24..
//

import SwiftUI
import os
let logger = Logger(subsystem: "screens", category: "Demo")

@Screen(alias: "UseCases")
struct UseCasesScreen {

  var screenBody: some View {
    UseCasesScreenBody()
  }
}

private struct UseCasesScreenBody: View {

  @State var appearanceInfo = ""

  var body: some View {
    
    List {
      Text(appearanceInfo)

      Section("Base Navigation (Screens.current)") {
        Text("Used current ScreenProxy to make navigation commands")

        Button("Fullscreen") {
          Screens.current.fullscreen(TestScreenWithStack(), modifier: .closeButton)
        }
        Button("Sheet (Default detens)") {
          Screens.current.sheet(TestScreenWithStack(), modifier: .closeButton)
        }

        Button("Sheet (Only medium)") {
          Screens.current.sheet(TestScreenWithStack(), modifier: .detents(.medium), .closeButton)
        }

        Button("Push") {
          Screens.current.push(TestScreen())
        }
      }

      Section("Base Actions ( Screens)") {
        Text("Used actions, which behavior can be commonly configured via ScreensDelegate")

        Button("Fullscreen") {
          Screens.fullscreen(TestScreenWithStack())
        }

        Button("Sheet") {
          Screens.sheet(TestScreenWithStack())
        }

        Button("Push") {
          Screens.push(TestScreen())
        }

        NavigationLink {
          TestScreen()
        } label: {
          Text("Push ( SwiftUI )")
        }
      }

      Section("Push-On-Appearance") {
        Text("Test behavior when screen pushed right in onAppear for fullscreen presentation")

        Button("Screens") {
          Screens.current.fullscreen(PushOnAppearScreens(), modifier: .inStack)
        }
        Button("Native") {
          Screens.current.fullscreen(PushOnAppearNative(), modifier: .inStack)
        }
      }
    }
    .onScreenAppear { appearance in
      appearanceInfo = appearance.appearance.description + " " + Date.now.formatted(.dateTime.hour().minute().second())
      logger.debug("UseCases onScreenAppear")
    }
    .navigationTitle("Use Cases")
  }
}


#Preview {
  UseCasesScreen()
}
