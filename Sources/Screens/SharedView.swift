//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

/// А feature that can be used in different independent application modules.
/// The feature body is implemented in one of the modules via the ``SharedscreenBody`` protocol
public protocol SharedView: View {
  associatedtype PlaceholderBody: View
  /// The placeholder will be shown where the feature body is not available
  @ViewBuilder @MainActor var placeholderBody: Self.PlaceholderBody { get }
}

public extension SharedView {
  var placeholderBody: some View {
    Text("[\(Self.self)]")
  }
}

/// Body implementation of ``SharedFeature``
public protocol SharedViewBody {
  associatedtype SharedBody: View
  @ViewBuilder var sharedBody: Self.SharedBody { get }
}
