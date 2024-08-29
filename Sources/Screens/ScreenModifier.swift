//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
import SwiftUI
import ScreensBrowser

/// Modifier to configure global features behavior
public struct ScreenModifier: ViewModifier {

  @StateObject private var controller: ScreenController
  @Environment(\.isPresented) var isPresented
  @Environment(\.dismiss) var dismiss
  @Environment(\.screenID) var parentScreenID

  public init<S: Screen>(_ screen: S.Type, alias: String?) {
    _controller = StateObject(wrappedValue: ScreenController(staticID: screen.screenID, alias: alias))
  }

  public func body(content: Content) -> some View {
    content
      .onPreferenceChange(ScreenNavigationDestinationPreferenceKey.self, perform: { [weak controller] value in
        controller?.hasNavigationDestination = value
      })
      .fullScreenCover(item: $controller.fullcreen) { $0.view }
      .sheet(item: $controller.sheet) { $0.view }
      .push(item: $controller.pushOuter) { $0.view }
      .environmentObject(controller)
      .environment(\.screenID, controller.id)
      .environment(\.screen, controller.screenInfo)

      .onDisappear { [weak controller] in
        controller?.onDissappear()
      }
      .onChange(of: isPresented, perform: { [weak controller] _ in
        controller?.isPresented = isPresented
      })
      .background {
        ViewControllerAccessor(controller: controller)
      }
      .onReceive(controller.doDismiss, perform: { _ in
        dismiss()
      })
      .onAppear { [weak controller] in
        controller?.parentScreenID = parentScreenID == .zero ? nil : parentScreenID
        controller?.isPresented = isPresented
        controller?.onAppear()
      }

  }
}

private struct ViewControllerAccessor: UIViewControllerRepresentable {
  let controller: ScreenController

  func makeUIViewController(context: Context) -> ScreenController {
    controller
  }

  func updateUIViewController(_ uiViewController: ScreenController, context: Context) {
  }
}

struct ScreenIDKey : EnvironmentKey {
  static var defaultValue: ScreenID = .zero
}

public extension EnvironmentValues {
  var screenID: ScreenID {
    get { self[ScreenIDKey.self] }
    set { self[ScreenIDKey.self] = newValue }
  }
}

struct ScreenKey : EnvironmentKey {
  static var defaultValue: ScreenInfo = .empty
}

public struct ScreenInfo: CustomStringConvertible {
  public let id: ScreenID
  public let type: String

  public var description: String {
    "\(type)[\(id)]"
  }

  public static var empty = ScreenInfo(id: 0, type: "")
}

public extension EnvironmentValues {
  var screen: ScreenInfo {
    get { self[ScreenKey.self] }
    set { self[ScreenKey.self] = newValue }
  }
}
