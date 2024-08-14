import SwiftUI
import BrowserMessages

/// A type that represents featue in your app.
public protocol Screen: View {
  typealias ID = String
  associatedtype ScreenBody: View
  @ViewBuilder @MainActor var screenBody: Self.ScreenBody { get }
  static var file: StaticString { get }
  static var alias: String? { get }
}


public extension Screen {
  static var alias: String? { nil }
  static var screenID: ScreenStaticID {
    ScreenStaticID(type: "\(Self.self)", file: file)
  }
}
