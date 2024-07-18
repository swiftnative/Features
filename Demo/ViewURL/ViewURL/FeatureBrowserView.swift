//
// Created by Alexey Nenastyev on 7.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

struct FeatureBrowserView: View {

  var body: some View {
    VStack {
      Button("Connect") {
        FeatureTree.shared.connect()
      }
      Button("Disconnect") {
        FeatureTree.shared.disconnect()
      }
    }
  }

}

#Preview {
  FeatureBrowserView()
}
