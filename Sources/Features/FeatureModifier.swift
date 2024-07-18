//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

/// Modifier to configure global features behavior
public struct FeatureModifier: ViewModifier {

  let file: StaticString
  let type: String
  let featureID: String

  public init<F: Feature>(_ feature: F.Type, featureID: String, file: StaticString = #file) {
    self.file = file
    self.type = F.type
    self.featureID = featureID
  }

  public func body(content: Content) -> some View {
    content
      .modifier(FeatureNodeModifier(type: type, featureID: featureID, file: file))
//      .onAppear {
//        FeatureDelegate.current?.onAppear(type, file: file)
//      }
//      .onDisappear {
//        FeatureDelegate.current?.onDisappear(type, file: file)
//      }
  }
}
