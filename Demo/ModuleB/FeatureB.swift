//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared
import Features

@Feature
public struct FeatureB {
  var text: String

  public init() {
    text = "Module B"
  }

  public var featureBody: some View {
    let view = SomeFeatureView(text: text) {
      SomeModel(feature: self)
    }
    return view 
  }
}

#Preview {
  FeatureB()
}

struct SomeFeatureView: View {
  var text: String
  @StateObject private var model: SomeModel

  init(text: String, model: @escaping () -> SomeModel) {
    self.text = text
    self._model = StateObject(wrappedValue: model())
  }

  var body: some View {
    VStack(spacing: 20) {
      DependenciesGraph(selected: text)

      Text("Module **B** implement nothing")

      ExpiredButton(title: "Tap now or never!",
                    logo: "b.square",
                    action: {})
      Spacer()
    }
    .navigationTitle("Module B")
  }
}

final class SomeModel: ObservableObject {
  let feature: FeatureB
  init(feature: FeatureB) {
    self.feature = feature
  }
}
