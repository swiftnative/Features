@_exported import SwiftUI

/// Body implementation of ``SharedFeature``
public protocol SharedFeatureBody {
  associatedtype SharedFeatureBody: View
  @ViewBuilder var sharedFeatureBody: Self.SharedFeatureBody { get }
}

/// A type that represents featue in your app.
public protocol Feature: View {
  associatedtype FeatureBody: View
  @ViewBuilder @MainActor var featureBody: Self.FeatureBody { get }
}

/// А feature that can be used in different independent application modules.
/// The feature body is implemented in one of the modules via the ``SharedFeatureBody`` protocol
public protocol SharedFeature: Feature {
  associatedtype PlaceholderBody: View
  /// The placeholder will be shown where the feature body is not available
  @ViewBuilder @MainActor var placeholderBody: Self.PlaceholderBody { get }
}

extension Feature {
  static var type: String { "\(Self.self)" }
}

public extension SharedFeature {
  var placeholderBody: some View {
    Text("[\(Self.self)]")
  }
}

/// Modifier to configure global features behavior
public struct FeatureModifier: ViewModifier {

  let file: StaticString
  let type: String

  public init<F: Feature>(_ feature: F.Type, file: StaticString = #file) {
    self.file = file
    self.type = F.type
  }

  public func body(content: Content) -> some View {
    content
      .onAppear {
        FeatureDelegate.current?.onAppear(type, file: file)
      }
      .onDisappear {
        FeatureDelegate.current?.onDisappear(type, file: file)
      }
  }
}
