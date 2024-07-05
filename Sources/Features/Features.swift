@_exported import SwiftUI

public protocol SharedFeatureBody {
  associatedtype SharedFeatureBody: View
  var sharedFeatureBody: SharedFeatureBody { get }
}

public protocol Feature: View {
  associatedtype FeatureBody: View
  var featureBody: FeatureBody { get }
}

public protocol SharedFeature: Feature {
  associatedtype PlaceholderBody: View
  var placeholderBody: PlaceholderBody { get }
}

extension Feature {
  static var type: String { "\(Self.self)" }
}

public extension SharedFeature {
  var placeholderBody: some View {
    Text("[\(Self.self)]")
  }
}

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
