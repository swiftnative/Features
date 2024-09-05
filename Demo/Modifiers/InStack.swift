//
//  InStack.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 26.8.24..
//

import SwiftUI

@available(iOS 16.0, *)
struct InStack: ViewModifier {

  @State var path = NavigationPath()

  func body(content: Content) -> some View {
    NavigationStack(path: $path) {
      content
    }
  }
}

@available(iOS 16.0, *)
extension ViewModifier where Self == InStack {
  static var inStack: Self { InStack() }
}
