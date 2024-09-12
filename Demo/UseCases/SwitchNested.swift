//
//  SwitchNestedScreen.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 9.9.24..
//

import SwiftUI
import ScreensUI

@Screen
struct SwitchNestedPicker: View {
  @State var animal: Animal? = .cat
  var screenBody: some View {
    ScreenStack {
      VStack {
        ScreenPicker(animal: $animal)
        Divider()
        if let animal {
          AnyView(animal.screen)
        }
      }
    }
  }
}

@Screen
struct SwitchNestedTab: View {
  @State var animal: Animal = .cat
  var screenBody: some View {
    TabView(selection: $animal) {
      Cats()
      .tabItem {
        Label(Animal.cat.name, systemImage: Animal.cat.systemImage)
      }
      .tag(Animal.cat)
      Dogs()
      .tabItem {
        Label(Animal.dog.name, systemImage: Animal.dog.systemImage)
      }
      .tag(Animal.dog)
    }
  }
}


@Screen
struct SwitchNestedPage: View {
  @State var animal: Animal = .cat
  var screenBody: some View {
    TabView(selection: $animal) {
      Cat()
        .tabItem {
          Label(Animal.cat.name, systemImage: Animal.cat.systemImage)
        }
        .tag(Animal.cat)

      Dog()
        .tabItem {
          Label(Animal.dog.name, systemImage: Animal.dog.systemImage)
        }
        .tag(Animal.dog)
    }
    .tabViewStyle(.page(indexDisplayMode: .always))
    .screenDetached
  }
}

#Preview {
  SwitchNestedPicker()
}

#Preview {
  SwitchNestedTab()
}

#Preview {
  SwitchNestedPage()
}
