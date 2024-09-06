//
//  UseCasesScreen.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 25.8.24..
//

import SwiftUI
import os
import ScreensUI

let logger = Logger(subsystem: "screens", category: "Demo")

@Screen(alias: "UseCases")
struct UseCasesScreen {

  var screenBody: some View {
    UseCasesScreenBody()
  }
}

private struct UseCasesScreenBody: View {
  @State var selectedPage: Pages = .navigation

  enum Pages: String {
    case navigation
    case actions
  }

  var body: some View {
    ScreenStack {
      VStack {
        Picker("Tab", selection: $selectedPage) {
          Text("Navigation")
            .tag(Pages.navigation)

          Text("Actions")
            .tag(Pages.actions)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
      }
      TabView(selection: $selectedPage) {
        NavigationPage()
          .tag(Pages.navigation  )

        ActionsPage()
          .tag(Pages.actions)
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      .navigationTitle("Screens")
    }
  }
}

@Screen
private struct NavigationPage {

  @State var appearanceInfo = ""

  var screenBody: some View {
    List {
      Text(appearanceInfo)

      Text("Used current ScreenProxy to make navigation commands")

      Button("Fullscreen") {
        Screens.current.fullscreen(TestScreenStackWrapped(), modifier: .closeButton)
      }
      Button("Sheet (Default detens)") {
        Screens.current.sheet(TestScreenStackWrapped(), modifier: .closeButton)
      }

      Button("Sheet (Only medium)") {
        if #available(iOS 16.0, *) {
          Screens.current.sheet(TestScreenStackWrapped(), modifier: .detents(.medium), .closeButton)
        } else {
          Screens.current.sheet(TestScreenStackWrapped(), modifier: .closeButton)
        }
      }

      Button("Push") {
        Screens.current.push(TestScreen())
      }
      Button("Push2") {
        Screens.current.push(TestScreen())
      }

      NavigationLink {
        TestScreen()
      } label: {
        Text("Push ( SwiftUI )")
      }

//      Section("Push-On-Appearance") {
//        Text("Test behavior when screen pushed right in onAppear for fullscreen presentation")
//
//        Button("Screens") {
//          Screens.current.fullscreen(PushOnAppearScreens(), modifier: .inStack)
//        }
//        Button("Native") {
//          Screens.current.fullscreen(PushOnAppearNative(), modifier: .inStack)
//        }
//      }
    }
    .onScreenAppear { appearance in
      appearanceInfo = appearance.appearance.description + " " + Date.now.formatted(.dateTime.hour().minute().second())
      logger.debug("NavigationPage onScreenAppear")
    }
  }
}

@Screen
private struct ActionsPage {

  @State var appearanceInfo = ""

  var screenBody: some View {
    Text("Actions")
      .onScreenAppear { appearance in
        logger.debug("ActionsPage onScreenAppear")
      }
  }
}
#Preview {
  UseCasesScreen()
}
