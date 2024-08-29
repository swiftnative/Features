//
// Created by Alexey Nenastyev on 17.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import Notifications
import SwiftUI
import ScreensBrowser

struct ScreenNavigationDestinationModifier: ViewModifier {
  @EnvironmentObject var controller: ScreenController
  @Environment(\.screenID) var screenID

  func body(content: Content) -> some View {
    content
      .push(item: $controller.pushNavigationDestination) { $0.view }
      .preference(key: ScreenNavigationDestinationPreferenceKey.self, value: true)
      .onAppear {
        controller.screenDestinationOnAppear()
      }
  }
}



public extension View {
  var screenNavigationDestination: some View {
    modifier(ScreenNavigationDestinationModifier())
  }
}

struct ScreenNavigationDestinationPreferenceKey: PreferenceKey {
  static var defaultValue = false

  static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}
