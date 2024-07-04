@_exported import SwiftUI

public protocol FeatureBody {
  associatedtype FeatureBody: View
  var featureBody: FeatureBody { get }
}

public protocol Feature: View {
}

public protocol SharedFeature: Feature {
  associatedtype PlaceholderBody: View
  var placeholderBody: PlaceholderBody { get }
}

public extension Feature {
  static var typeID: String { "\(Self.self)" }
}

public extension SharedFeature {
  var placeholderBody: some View {
    Text("[\(Self.self)]")
  }
}

