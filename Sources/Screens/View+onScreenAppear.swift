//
//  File.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//

import SwiftUI


public extension View {
  func onScreenAppear(_ perform: @escaping (ScreenAppearance) -> Void) -> some View {
    modifier(ScreenAppearModifier(perform: perform))
  }
}

fileprivate struct ScreenAppearModifier: ViewModifier {
  @EnvironmentObject var controller: ScreenController
  
  let perform: (ScreenAppearance) -> Void

  func body(content: Content) -> some View {
    content
      .onReceive(controller.onScreenAppear, perform: perform)
  }
}
