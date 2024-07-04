//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared

public struct FeatureC: View {
  public init() {}

  public var body: some View {
    VStack(spacing: 20) {
      DependenciesGraph(selected: "Module C")

      Text("Module **C** implement ExpiredButton")

      ExpiredButton(title: "Tap now or never!",
                    logo: "c.square",
                    action: {})
      Spacer()
    }
    .navigationTitle("Module C")
  }
}

#Preview {
    FeatureC()
}
