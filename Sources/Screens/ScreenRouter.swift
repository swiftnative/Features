//
//  ScreenRouter.swift
//  Screens
//
//  Created by Alexey Nenastev on 11.9.24..
//
import SwiftUI
import ScreensBrowser
import os

final class ScreenRouter: ObservableObject {
  /// Navigation
  @Published var fullcreen: ScreenRouteRequest?
  @Published var sheet: ScreenRouteRequest?
  @Published var pushOuter: ScreenRouteRequest? {
    willSet {
      if let pushOuter, newValue != nil  {
        Logger.screens.error("[\(self.logID)] unextected pushOuter is not nil (\(pushOuter.debugDescription)), when push \(newValue.debugDescription)")
      }
    }
    didSet {
      if let pushOuter  {
        Logger.swiftui.log("\(self.logID) set new pushOuter \(pushOuter.debugDescription)")
      } else  {
        Logger.swiftui.log("\(self.logID) clear pushOuter")
      }
    }
  }
  @Published var pushNavigationDestination: ScreenRouteRequest? {
    willSet {
      if let pushNavigationDestination, newValue != nil  {
        Logger.screens.error("[\(self.logID)] unextected pushNavigationDestination is not nil (\(pushNavigationDestination.debugDescription)), when push \(newValue.debugDescription)")
      }
    }
    didSet {
      if let pushNavigationDestination  {
        Logger.swiftui.log("\(self.logID) set new pushNavigationDestination \(pushNavigationDestination.debugDescription)")
      } else  {
        Logger.swiftui.log("\(self.logID) clear pushNavigationDestination")
      }
    }
  }



  var logID: String { "\(controller?.logID ?? "")" }

  weak var controller: ScreenController?

  private var pendingRequest: ScreenRouteRequest?

  func screenReadyToRoute(){
    processPendingRequest()
  }

  func request(_ request: ScreenRouteRequest) {
    pendingRequest = request
    processPendingRequest()
  }

  private func processPendingRequest() {
    guard let request = pendingRequest,
          let controller,
          let viewController = controller.viewController,
          controller.readyToRoute
    else { return }
    Logger.router.debug("\(controller.logID) will \(request.kind.rawValue) \(request.screenStaticID.description)")
    Screens.shared.screen(kind: .route(request.screenStaticID, request.kind), for: controller)

    defer { self.pendingRequest = nil }



    switch request.kind {
    case .push:
      if controller.detachedScreen {
        if controller.hasNavigationDestination {
          DispatchQueue.main.async {
            self.pushNavigationDestination = request
          }
        } else {
          DispatchQueue.main.async {
            self.pushOuter = request
          }
        }
      } else {
        if viewController.navigationController != nil  {
          DispatchQueue.main.async {
            self.pushOuter = request
          }
        } else if controller.hasNavigationDestination {
          DispatchQueue.main.async {
            self.pushNavigationDestination = request
          }
        } else {
          Logger.router.error("\(controller.logID) can't push \(request.screenStaticID.description), no navigation controller")
        }
      }
    case .fullscreen:
      fullcreen = request
    case .sheet:
      sheet = request
    }
  }
}
