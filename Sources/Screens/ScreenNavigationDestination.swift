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
  @EnvironmentObject var router: ScreenRouter
  @State var appeared: Bool = false
  @State var skip: Bool = false
  @Environment(\.screen) var screenInfo

  
  func body(content: Content) -> some View {
    let binding: Binding<ScreenRouteRequest?> = skip ? .constant(nil) : $router.pushNavigationDestination
    content
      .push(item: binding)
      .onAppear { [weak controller] in
        guard let controller else { return }
        if !appeared {
          skip = controller.hasNavigationDestination
          appeared = true
          controller.hasNavigationDestination = true
        }
        if !skip {
          controller.onNavigationDestinationAppear()
        }
      }
  }
}

public extension View {
  var screenNavigationDestination: some View {
    modifier(ScreenNavigationDestinationModifier())
  }
}
