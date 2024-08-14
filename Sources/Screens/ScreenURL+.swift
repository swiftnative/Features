//
// Created by Alexey Nenastyev on 6.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import BrowserMessages

public extension ScreenURL {
   func callAsFunction<S: Screen>(by type: S.Type) where S: ScreenURLDecodable {
    do {
      let screen = try S(from: ScreenURLParams(params: params))
      Screens.delegate.action(host, screen: screen, params: query)
    } catch {
      Screens.browser?.send(message: .screenURLError(self, "\(error)"))
      Screens.delegate.didFailToOpen(url: self, error: error)
    }
  }
}
