//
//  TestScreen.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 25.8.24..
//

import SwiftUI
import ScreensUI

@Screen
struct TestScreen {
  var screenBody: some View {
    TestView()
      .presentationDetents([.medium, .large])
  }
}

@Screen
struct TestScreenWrapper {
  var screenBody: some View {
    TestScreen()
  }
}

@Screen
struct TestScreenWithStack {

  var screenBody: some View {
    ScreenStack {
      TestView()
    }
    .presentationDetents([.medium, .large])
  }
}

fileprivate struct TestView:  View {
  @State var current: String = Screens.current.description
  @Environment(\.screen) var screen
  @State var appearance: ScreenAppearance?
  
  // Native
  @Environment(\.dismiss) var dismiss
  @State var fullscreen = false
  @State var sheet = false
  
  @AppStorage("ScreensToOpen") var screenToOpen = ScreensToOpen.test

  enum ScreensToOpen: Int {
    case test
    case testWithStack
    case testWrapper

    var screen: any Screen {
      switch self {
      case .test: TestScreen()
      case .testWithStack: TestScreenWithStack()
      case .testWrapper: TestScreenWrapper()
      }
    }

    var screenSwiftUI: some View {
      Group {
        switch self {
        case .test: TestScreen()
        case .testWithStack: TestScreenWithStack()
        case .testWrapper: TestScreenWrapper()
        }
      }
    }
  }

  

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      if let appearance {
        Text("Appearance")
          .font(.title2)
        Text("Current: \(appearance.appearance)")
          .font(.subheadline.monospaced())
        Text("First: \(appearance.firstAppearance)")
          .font(.subheadline.monospaced())
        Text("Count: \(appearance.count)")
          .font(.subheadline.monospaced())
      }
      Divider()

      Picker("Screent to open", selection: $screenToOpen) {
        Text("Test")
          .tag(ScreensToOpen.test)
        Text("Test-with-Stack")
          .tag(ScreensToOpen.testWithStack)
        Text("TestWrapper")
          .tag(ScreensToOpen.testWrapper)
      }
      .pickerStyle(.navigationLink)
      HStack {
        VStack {
          Text("Screens")
            .font(.title2)
          Button("dismiss") {
            Screens.dismiss()
          }
          Button("push") {
            Screens.push(screenToOpen.screen)
          }
          Button("fullscreen") {
            Screens.fullscreen(screenToOpen.screen)
          }
          Button("sheet") {
            Screens.sheet(screenToOpen.screen)
          }
        }

        VStack {
          Text("SwiftUI")
            .font(.title2)
          Button("dismiss") {
            dismiss()
          }

          NavigationLink {
            screenToOpen.screenSwiftUI
          } label: {
            Text("push")
          }

          Button("fullscreen") {
            fullscreen.toggle()
          }
          Button("sheet") {
            sheet.toggle()
          }
        }
        .sheet(isPresented: $sheet, content: {
          screenToOpen.screenSwiftUI
        })
        .fullScreenCover(isPresented: $fullscreen) {
          screenToOpen.screenSwiftUI
        }
      }
      Spacer()
      Divider()
      VStack(alignment: .leading, spacing: 5) {
        HStack {
          Text("Screens.current")
            .font(.title2)

          Button("Refresh") {
            current = Screens.current.description
          }
          .buttonStyle(.borderless)
        }
        Text("\(current)")
          .font(.subheadline.monospaced())

      }
    }
    .onScreenAppear {
      current = Screens.current.description
      appearance = $0
      logger.debug("\(screen.description) onScreenAppear")
    }
    .padding()
    .navigationTitle(screen.description)
    .navigationBarTitleDisplayMode(.inline)
    .accessibilityIdentifier("TestScreen")
    .buttonStyle(.bordered)
  }
}


#Preview {
  NavigationView {
    TestScreen()
  }
}
