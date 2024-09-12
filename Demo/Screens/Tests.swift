//
//  Tests.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 9.9.24..
//

import SwiftUI
import ScreensUI

@Screen
struct Tests {

  func button(_ name: String, _ description: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          Text(name)
            .bold()
          Text(description)
            .multilineTextAlignment(.leading)
            .font(.callout)
        }
        .padding(.vertical, 6)
        Spacer()
      }
    }
    .accessibilityIdentifier(name)
    .foregroundStyle(.primary)
    .padding(.horizontal)
  }

  func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.title)
        .padding(.horizontal)
      content()
    }
  }

  var screenBody: some View {
    ScreenStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {

          section("Base") {
            button("FullScreen (Stack-Wrapped)",
                   "Push Dog as Fullscreen") {
              Screens.current.fullscreen(Dog(), modifier: .screenStack, .closeButton)
            }

            button("FullScreen (Stack-Inside)",
                   "Push Dogs as Fullscreen") {
              Screens.current.fullscreen(Dogs(), modifier: .closeButton)
            }

            button("Sheet",
                   "Push Dog as Sheet") {
              Screens.current.sheet(Dog(), modifiers: .screenStack, .closeButton, .detents(.medium, .large))
            }
            
            button("Push",
                   "Push screen Dog") {
              Screens.push(Dog())
            }
            
            button("Push, Push",
                   "Push Cat, Dog") {
              let screen = Cat { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  Screens.current.push(Dog())
                }
              }
              Screens.current.push(screen)
              
            }
          }

          section("Dismiss") {

            button("Close fullscreen",
                   "Push screen Dog just after screen Cat appeared") {
              let screen = Cat { _ in
                Screens.push(Cat { _ in
                  Screens.push(Dog())
                })
              }
              Screens.current.fullscreen(screen, modifier: .screenStack, .closeButton)

              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Screens.current.close()
              }
            }

            button("Dismiss Fullscreen",
                   "Dismiss Dog screen - shoul close fullscreen") {
              let screen = Dog()
              Screens.current.fullscreen(screen, modifier: .screenStack, .closeButton)

              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Screens.current.dismiss()
              }
            }

            button("Dismiss Pushed",
                   "Dismiss pushed Dog screen - shoul back one step") {
              let screen = Dog()
              Screens.current.push(screen)

              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Screens.current.dismiss()
              }
            }

            button("Pop-to-Root",
                   "Push Cat, Dog and than pop-to-root") {
              let screen = Cat { _ in
                Screens.current.push(Dog())
              }
              Screens.current.push(screen)

              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Screens.current.popToRoot()
              }
            }
          }

          section("Sequence") {
            button("Push-on-Appear",
                   "Push screen Dog just after screen Cat appeared") {
              let screen = Cat { _ in
                Screens.push(Dog())
              }
              Screens.current.fullscreen(screen, modifier: .screenStack, .closeButton)
            }
            button("SwiftUI.Push-on-Appear",
                   "Push screen Dog just after screen Cat appeared") {
              Screens.current.push(SwiftUIOnAppear())
            }

          }

          section("Nested") {

            button("Nested screens",
                   "Fullscreen Screen in stack with nested screens") {
              Screens.current.fullscreen(SwitchNestedPicker(), modifier: .closeButton)
            }

            button("Nested screens in Tab",
                   "Fullscreen Tab wrapped in stack with nested screens") {
              Screens.current.fullscreen(SwitchNestedTab(), modifier: .closeButton)
            }

            button("Dog-Cat Carousel",
                   "Fullscreen Tab with style 'pages' wrapped in stack with nested screens") {
              Screens.current.fullscreen(PetsCarousel(), modifier: .screenStack, .closeButton)
            }
          }
        }
      }
      .accessibilityIdentifier("tests")
      .buttonStyle(.bordered)
      .navigationTitle("Screens")
    }
  }
}

#Preview {
  Tests()
}
