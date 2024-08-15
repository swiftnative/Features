import Features

#if canImport(UIKit)
import UIKit
import SwiftUI

@Screen(path: "my")
struct My {

  init() {}

  init(from params: Params) throws {
    self.init()
  }

  var screenBody: some View {
    Text("My")
  }
}


@Screen
@SharedView
struct SomeScreen {
  init() {}
}

extension SomeScreen: SharedViewBody {
  var sharedBody: some View {
    VStack {
      Text("SomeScreen")
      Button("Dismiss") {
        Screens.current.dismiss()
      }
    }
  }
}

#endif
