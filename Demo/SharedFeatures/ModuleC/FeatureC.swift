//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared
import Features

@Screen
public struct FeatureC: View {
  @State var buttonTitle: String = "Tap will change title"
  public init() {}

  public var screenBody: some View {
    VStack(spacing: 20) {
      DependenciesGraph(selected: "Module C")

      Text("Module **C** implement ExpiredButton")

      ExpiredButton(title: buttonTitle,
                    logo: "c.square") {
        buttonTitle = "New title"
      }
      Spacer()
    }
    .navigationTitle("Module C")
  }
}

#Preview {
    FeatureC()
}
