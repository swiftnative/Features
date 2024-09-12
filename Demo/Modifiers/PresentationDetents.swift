//
//  PresentationDetents.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 26.8.24..
//

import SwiftUI

struct PresentationDetentsModifier: ViewModifier {
  let detents: Set<Detent>

  enum Detent: Hashable {
    case medium
    case large

    @available(iOS 16.0, *)
    var presentationDetent: PresentationDetent {
      switch self {
      case .medium: return .medium
      case .large: return .large
      }
    }
  }

  func body(content: Content) -> some View {
    if #available(iOS 16.0, *) {
      content
        .presentationDetents(Set(detents.map { $0.presentationDetent }))
    } else {
      content
    }

  }
}

extension ViewModifier where Self == PresentationDetentsModifier {
  static func detents(_ detents: PresentationDetentsModifier.Detent...) -> Self {
    PresentationDetentsModifier(detents: Set(detents))
  }
}

