//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
import SwiftUI
import BrowserMessages

/// Modifier to configure global features behavior
public struct ScreenModifier: ViewModifier {

  @StateObject private var controller: ScreenController
  @Environment(\.isPresented) var isPresented
  @Environment(\.dismiss) var dismiss
  @Environment(\.screenID) var parentScreenID
  @Environment(\.self) var environment
  @State var screenEnvironmentID = UUID()

  public init<S: Screen>(_ screen: S.Type, alias: String?) {
    _controller = StateObject(wrappedValue: ScreenController(staticID: screen.screenID, alias: alias))
  }

  public func body(content: Content) -> some View {
    content
      .environment(\.screenID, controller.id)
      .onAppear { [weak controller] in
        controller?.onAppear(parentScreenID: parentScreenID,
                             isPresented: isPresented,
                             dismiss: dismiss)
        controller?.environment = environment
      }
      .onDisappear { [weak controller] in
        controller?.onDissappear()
      }
      .onChange(of: isPresented) { [weak controller] in
        controller?.onIsPresentedChanged(isPresented: $0, dismiss: dismiss)
      }
      .background {
        ViewControllerAccessor(controller: controller)
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

struct ParentScreenIDKey : EnvironmentKey {
  static var defaultValue: UUID = .zero
}

public extension EnvironmentValues {
  var screenID: ScreenID {
    get { self[ParentScreenIDKey.self] }
    set { self[ParentScreenIDKey.self] = newValue }
  }
}
