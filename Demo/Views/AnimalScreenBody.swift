//
//  Dog.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 9.9.24..
//

import SwiftUI
import ScreensUI

struct AnimalScreenBody: View {
  @State var animal: Animal
  @State var animalToOpen: Animal? = .dog
  @State var appearance: ScreenAppearance?
  @Environment(\.screen) var screen
  @State var currentScreen = Screens.current.description

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top, spacing: 40) {
        Image(systemName: animal.systemImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 100)
          .padding()
        VStack(alignment: .leading, spacing: 10) {
          Section(header: Text("Screen").font(.title2)) {
            Label(screen.type.description, systemImage: "person.text.rectangle")
              .accessibilityIdentifier("screen.type")
            Label(appearance?.description ?? "-", systemImage: "bubbles.and.sparkles.fill")
              .accessibilityIdentifier("screen.appearance")
          }
        }
        Spacer()
      }
      .padding(.vertical, 20)
      Divider()
        .padding(.horizontal, -16)
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 20) {

          Spacer(minLength: 0)

          Section(header: Text("Do").font(.title2)) {
            VStack(alignment: .leading) {
              button("Dismiss", description: "Dismiss current screen, equivalent to environment dismiss") {
                Screens.dismiss()
              }
              .accessibilityIdentifier("dismiss")

              button("Pop-to-Root", description: "If screen in stack then goes to root") {
                Screens.popToRoot()
              }
              .accessibilityIdentifier("pop-to-root")

              button("Close", description: "Close modal presented screen") {
                Screens.close()
              }
              .accessibilityIdentifier("close")
            }
          }

          if let animalToOpen {
            Section(header: Text("Open").font(.title2)) {
              ScreenPicker(animal: $animalToOpen)

              VStack(alignment: .leading) {
                button("Push", description: "Push \(animalToOpen.name) to stack") {
                  Screens.push(animalToOpen.screen)
                }
                .accessibilityIdentifier("push")

                button("Fullscreen", description: "Fullscreen \(animalToOpen.name)") {
                  Screens.current.fullscreen(animalToOpen.screen, modifier: .screenStack, .closeButton)
                }
                .accessibilityIdentifier("fullscreen")

                button("Sheet", description: "Sheet \(animalToOpen.name)") {
                  Screens.current.sheet(animalToOpen.screen, modifiers: .screenStack, .closeButton, .detents(.medium, .large))
                }
                .accessibilityIdentifier("sheet")
              }
            }
          }
          VStack(alignment: .leading, spacing: 10) {
            Section(header: Text("Current Screen").font(.title3)) {
              Label(currentScreen, systemImage: "target")
                .accessibilityIdentifier("current-screen")
            }
          }

        }
      }
    }
    .buttonStyle(.bordered)
    .padding(.horizontal)
    .onScreenAppear { appearance in
      print("ScreenAppear \(screen.description) \(appearance.appearance.description)")
      self.appearance = appearance
      self.currentScreen = Screens.current.description
    }
    .navigationTitle(screen.description)
  }

  func button(_ title: String, description: String, action: @escaping () -> Void) -> some View {
    HStack {
      Button(title, action: action)
      Text(description)
        .font(.footnote)
    }
  }
}

@Screen
fileprivate struct PreviewScreen {

  var screenBody: some View {
    AnimalScreenBody(animal: .cat)
  }
}

#Preview {
  PreviewScreen()
}
