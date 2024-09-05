//
//  PresentationDetents.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 26.8.24..
//

import SwiftUI

@available(iOS 16.0, *)
struct PresentationDetentsModifier: ViewModifier {
  let detents: Set<PresentationDetent>

  func body(content: Content) -> some View {
    content
      .presentationDetents(detents)
  }
}

@available(iOS 16.0, *)
extension ViewModifier where Self == PresentationDetentsModifier {
  static func detents(_ detents: PresentationDetent...) -> Self {
    PresentationDetentsModifier(detents: Set(detents))
  }
}
