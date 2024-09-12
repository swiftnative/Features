//
//  NewScreenOnAppear.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 25.8.24..
//

import SwiftUI
import ScreensUI

@Screen
struct PushOnAppear {

  var screenBody: some View {
    Cat(onScreenAppear: { _ in
      Screens.push(Dog())
    })
  }
}

#Preview {
  PushOnAppear()
}
