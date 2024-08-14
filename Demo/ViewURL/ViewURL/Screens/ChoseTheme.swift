//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

@Screen(alias: "ChoseTheme", path: "theme")
struct ChoseThemeScreen {

  @Environment(\.dismiss) var dismiss

  var screenBody: some View {
    VStack {
      Text("PushedView")
      Button("Dismiss") {
        dismiss()
      }

      Button("Dismiss via Screens") {
        Screens.current.dismiss()
      }
    }
  }

  init() {}

  init(from params: Params) throws {
  }
}



#Preview {
    ChoseThemeScreen()
}
