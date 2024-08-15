//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared
import Features

@Screen
public struct FeatureA: View {
  public init() {}

  public var screenBody: some View {
    VStack(spacing: 20) {
      DependenciesGraph(selected: "Module A")

      Text("Module **A** implement DependenciesGraph")

      ExpiredButton(title: "Tap now or never!",
                    logo: "a.square",
                    action: {})
      
      Spacer()
    }
    .navigationTitle("Module A")
  }
}

#Preview {
  FeatureA()
}
