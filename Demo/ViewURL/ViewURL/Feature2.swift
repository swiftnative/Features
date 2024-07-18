//
// Created by Alexey Nenastyev on 7.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

@Feature
struct Feature2 {
  var featureBody: some View {
    
    VStack {
      Text(featureID)
      Text("[feature1](app://feature1)")
    }
    .padding()
    .background(Color.red.opacity(0.2))
  }
}


#Preview {
    Feature2()
}
