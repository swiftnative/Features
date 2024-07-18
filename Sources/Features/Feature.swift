@_exported import SwiftUI

/// A type that represents featue in your app.
public protocol Feature: View {
  associatedtype FeatureBody: View
  @ViewBuilder @MainActor var featureBody: Self.FeatureBody { get }

  var featureID: String { get }
}

public extension Feature {
  static var type: String { "\(Self.self)" }
  var featureID: String { Self.type }
}



