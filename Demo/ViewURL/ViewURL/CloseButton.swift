//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

struct CloseButton: View {
    var body: some View {
      Button("", systemImage: "xmark.circle.fill") {
        Screens.current.close()
      }
    }
}

struct CloseButtonModifier: ViewModifier {
  func body(content: Content) -> some View {
    ZStack {
      Color.clear
      content
    }
      .overlay(alignment: .topTrailing) {
        CloseButton()
          .padding()
      }
  }
}

extension ViewModifier where Self == CloseButtonModifier {
  static var closeButton: Self {
    CloseButtonModifier()
  }
}

#Preview {
    CloseButton()
}
