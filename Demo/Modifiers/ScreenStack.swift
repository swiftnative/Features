//
//  ScreenStack.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 9.9.24..
//

import Foundation
import SwiftUI
import ScreensUI

struct ScreenStackModifier: ViewModifier {

  func body(content: Content) -> some View {
    ScreenStack {
      content
    }
  }
}

extension ViewModifier where Self == ScreenStackModifier {
  static var screenStack: Self { ScreenStackModifier() }
}
