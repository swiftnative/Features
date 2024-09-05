//
//  Native.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 26.8.24..
//

import SwiftUI
import ScreensUI

@available(iOS 17.0, *)
@Screen
struct PushOnAppearNative {
  @State var presented: ScreenAppearRequest?

  var screenBody: some View {
    TestScreen()
      .onAppear {
        presented =  ScreenAppearRequest(screenStaticID: TestScreen.screenID,
                                         view: AnyView(TestScreen().modifier(EmptyModifier())))
      }
      .navigationDestination(item: $presented, destination: {
        $0.view
      })
  }
}




#Preview {
  if #available(iOS 17.0, *) {
    PushOnAppearNative()
  } else {
    // Fallback on earlier versions
  }
}
