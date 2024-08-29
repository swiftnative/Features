//
//  PresentationDetents.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 26.8.24..
//

import SwiftUI

struct PresentationDetentsModifier: ViewModifier {
  let detents: Set<PresentationDetent>

  func body(content: Content) -> some View {
    content
      .presentationDetents(detents)
  }
}

extension ViewModifier where Self == PresentationDetentsModifier {
  static func detents(_ detents: PresentationDetent...) -> Self {
    PresentationDetentsModifier(detents: Set(detents))
  }
}
