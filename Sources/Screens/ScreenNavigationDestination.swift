//
// Created by Alexey Nenastyev on 17.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import Notifications
import SwiftUI
import ScreensBrowser
import os

struct ScreenNavigationDestinationModifier: ViewModifier {
  @EnvironmentObject var controller: ScreenController
  @Environment(\.screenID) var screenID
  @State var appeared: Bool = false
  @State var skip: Bool = false

  func body(content: Content) -> some View {
    Group {
      if skip {
        content
      } else {
        content
          .push(item: $controller.pushNavigationDestination) { $0.view }
      }
    }
    .onAppear { [weak controller] in
      guard let controller else { return }
      if !appeared {
        skip = controller.hasNavigationDestination
        appeared = true
      }
      if !skip {
        controller.onNavigationDestinationAppear()
      }
    }
//    .onDisappear { [weak controller] in
//      guard let controller else { return }
//      if !skip {
//        guard controller.innerNC != nil else { return }
//        Logger.swiftui.log("\(controller.logID) screenDestinationOnDisappear")
//        controller.onDissappear()
//      }
//    }
  }
}



public extension View {
  var screenNavigationDestination: some View {
    modifier(ScreenNavigationDestinationModifier())
  }
}
