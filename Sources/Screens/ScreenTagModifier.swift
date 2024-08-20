//
// Created by Alexey Nenastyev on 15.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI
import ScreensBrowser
import Notifications

public typealias ScreenTag = String

struct ScreenTagModifier: ViewModifier {
  @Environment(\.screenID) var screenID
  @State var tag: ScreenTag

  func body(content: Content) -> some View {
    content
      .onChange(of: tag) { newValue in
        if newValue != tag {
          Screens.shared.screen(set: tag, for: screenID)
        }
      }
      .task {
        Screens.shared.screen(set: tag, for: screenID)
      }
  }
}

public extension View {
  func screen(tag: ScreenTag) -> some View {
    modifier(ScreenTagModifier(tag: tag))
  }
}
