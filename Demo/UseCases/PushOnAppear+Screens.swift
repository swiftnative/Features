//
//  NewScreenOnAppear.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 25.8.24..
//

import SwiftUI

@Screen
struct PushOnAppearScreens {
  
  var screenBody: some View {
    TestScreen()
      .onAppear {
        Screens.push(TestScreen())
      }
  }
}

#Preview {
  PushOnAppearScreens()
}
