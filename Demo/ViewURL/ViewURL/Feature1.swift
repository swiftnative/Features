//
// Created by Alexey Nenastyev on 5.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

@Feature
struct Feature1 {
  @Environment(\.dismiss) var dismiss
  @StateObject private var model = FeatureModel()
  @State var sheet = false
  @State var id = UUID()

  var featureID: String {
    "Feature-\(id.uuidString.prefix(5))"
  }


  @ViewBuilder
  var featureBody: some View {
    VStack(spacing: 20) {

      Text(featureID)

      Button("dismiss") {
        dismiss()
      }

      
      NavigationLink("New Feature") {
        Feature1()
      }
 

      Button("Sheet") {
        sheet.toggle()
      }
    }
    .onAppear { [weak model] in
      model?.id = featureID
    }
    .padding()
    .background(Color.gray.opacity(0.3))
    .sheet(isPresented: $sheet) {
      Feature1()
    }
  }
}


final class FeatureModel: ObservableObject {

  var id: String!

  deinit {
//    print("DEINIT \(id)")
  }
}

#Preview {
  Feature1()
}
