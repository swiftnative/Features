//
//  File.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//

import SwiftUI

struct PushViewModifier: ViewModifier {
  @Binding var item: ScreenRouteRequest?
  @State var presented: Bool = false

  var pushedScreen: some View {
    PushedScreen(item: item)
  }

  private var isActiveBinding: Binding<Bool> {
    Binding(
      get: { item != nil },
      set: { isShowing in
        guard !isShowing else { return }
        guard item != nil else { return }
        item = nil
      }
    )
  }

  struct PushedScreen: View {
    var item: ScreenRouteRequest?

    var body: some View {
      if let item {
        item.view
      }
    }
  }

  func body(content: Content) -> some View {
    content
      ._navigationDestination(isActive: isActiveBinding, destination: pushedScreen)
  }
}

extension View {
  func push(item: Binding<ScreenRouteRequest?>) -> some View {
    modifier(PushViewModifier(item: item))
  }
}
