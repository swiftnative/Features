//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import Features

@SharedFeature
public struct ExpiredButton {
  public let title: String
  public let logo: String
  public let action: () -> Void

  public init(title: String,
              logo: String,
              action: @escaping () -> Void) {
    self.title = title
    self.logo = logo
    self.action = action
  }
}

@SharedFeature
public struct DependenciesGraph {
  public let selected: String

  public init(selected: String) {
    self.selected = selected
  }

  public var placeholderBody: some View {
    Text("DependenciesGraph")
      .frame(minWidth: 0, maxWidth: .infinity)
      .frame(height: 350)
      .border(Color.gray)
  }
}
