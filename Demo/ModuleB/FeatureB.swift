//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared
import Features

@Feature
public struct FeatureB {
  public init() {}

  public var featureBody: some View {
    VStack(spacing: 20) {
      DependenciesGraph(selected: "Module B")

      Text("Module **B** implement nothing")

      ExpiredButton(title: "Tap now or never!",
                    logo: "b.square",
                    action: {})
      Spacer()
    }
    .navigationTitle("Module B")
  }
}

#Preview {
  FeatureB()
}
