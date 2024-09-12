//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
import SwiftUI
import ScreensBrowser
import Combine
import os

/// Modifier to configure global features behavior
public struct ScreenModifier: ViewModifier {

  @StateObject private var controller: ScreenController
  @StateObject private var router: ScreenRouter
  @Environment(\.isPresented) var isPresented
  @Environment(\.dismiss) var dismiss
  @Environment(\.screenID) var parentScreenID
  @Environment(\.screenAddress) var parentScreenAddress
  @Environment(\.detachedScreen) var detachedScreen

  public init<S: Screen>(_ screen: S.Type, alias: String?) {
    _controller = StateObject(wrappedValue: ScreenController(staticID: screen.screenID, alias: alias))
    _router = StateObject(wrappedValue: ScreenRouter())
  }

  public func body(content: Content) -> some View {
    content
      .fullScreenCover(item: $router.fullcreen) { $0.view }
      .sheet(item: $router.sheet) { $0.view }
      .push(item: $router.pushOuter)
      .environmentObject(controller)
      .environmentObject(router)
      .environment(\.screenID, controller.id)
      .environment(\.screenAddress, controller.address)
      .environment(\.screen, controller.screenInfo)
      .environment(\.detachedScreen, false)
      .onChange(of: isPresented, perform: { [weak controller] newValue in
        controller?.onIsPresentedChanged(newValue)
      })
      .background {
        ViewControllerAccessor(controller: controller)
            .frame(width: 0, height: 0)
            .accessibility(hidden: true)
      }
      .onReceive(controller.doDismiss, perform: { _ in
        dismiss()
      })
      .onDisappear { [weak controller] in
        controller?.onDissappear()
      }
      .onAppear { [weak controller] in
        controller?.set(parent: parentScreenID, address: parentScreenAddress)
        controller?.detachedScreen = detachedScreen
        controller?.isPresented = isPresented
        controller?.onAppear()
      }
      .task { [weak controller, weak router] in
        controller?.router = router
        router?.controller = controller
      }
  }
}

private struct ViewControllerAccessor: UIViewControllerRepresentable {

  let controller: ScreenController

  func makeUIViewController(context: Context) -> ScreenViewController {
    let vc = ScreenViewController(id: controller.id, staticID: controller.staticID)
    controller.set(vc: vc)
    Logger.swiftui.log("\(controller.logID) makeUIViewController \(vc.vcID.pointer)")
    return vc
  }

  func updateUIViewController(_ uiViewController: ScreenViewController, context: Context) {
//    print("updateUIViewController \(controller.logID) \(context.environment.screenID) \(context.environment.isPresented)")
  }

  func dismantleUIViewController(_ uiViewController: ScreenViewController) {
    Logger.swiftui.log("\(controller.logID) dismantleUIViewController \(uiViewController.vcID.pointer)")
  }
}
