//
//  File 2.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import SwiftUI
import ScreensBrowser


extension Screens: BrowserDelegate {

  func recieved(message: BrowserMessage.From) {
    Task { @MainActor in
      switch message {
      case .screenURL(let url):
        Screens.open(url: url)
      case .sendAppication:
        browser?.send(message: .application(getApplication()))
      case .sendAppState:
        browser?.send(message: .appLiveState(getAppLiveState()))
      case .sendScreenInfo(let id):
        guard let screen = screen(by: id) else { return }
        browser?.send(message: .screen(screen.info))
      case .dismiss(let id):
        guard let screen = screen(by: id) else { return }
        screen.dismiss()
      case .sendAllScreens:
        browser?.send(message: .screensStaticInfo(getScreensStatic()))
      }
    }
  }

  func sendState() {
    Task { @MainActor in
      let state =  getAppLiveState()

      browser?.send(message: .appLiveState(state))
    }
  }

  func failed(error: any Error) {
    print("Failed with: \(error)")
  }

}

extension ScreenURLDecodable {
  static var params: [String] {
    if let p = ParamsKey.self as? any CaseIterable.Type {
      let coll =  p.allCases as any Collection
      return coll.map { "\($0)" }
    } else {
      return []
    }
  }
}

private extension Screens {

  func getScreensStatic() -> [ScreenStaticInfo] {

    Self.delegate.screens.map { screen in

      let path: String?
      let params: [String]?

      if let decodable = screen as? (any ScreenURLDecodable.Type) {
        path = decodable.path
        params = decodable.params
      } else {
        path = nil
        params = nil
      }

      return ScreenStaticInfo(staticID: screen.screenID,
                              alias: screen.alias,
                              path: path,
                              params: params,
                              description: "")
    }
  }

  func getApplication() -> AppInfo {
    .current
  }

  @MainActor
  func getAppLiveState() -> AppLiveState {

    var viewContollers: [Tree<ViewController>] = []

    func collectViewControllers(uiVC: UIViewController, parent: Tree<ViewController>? = nil) {
      let tree = Tree(value: uiVC.info)

      if let parent {
        if parent.children == nil {
          parent.children = [tree]
        } else {
          parent.children?.append(tree)
        }

      } else {
        viewContollers.append(tree)
      }

      for child in uiVC.children {
        collectViewControllers(uiVC: child, parent: tree)
      }
    }

    controllers.compact()

    controllers
      .all()
      .compactMap { $0.viewController }
      .uniqRootParanets
      .forEach { collectViewControllers(uiVC: $0, parent: nil) }

    let screens = controllers.info()
    let current = current?.id
    let info = AppLiveState(screens: screens,
                            viewControllers: viewContollers,
                            current: current)
    return info
  }
}

