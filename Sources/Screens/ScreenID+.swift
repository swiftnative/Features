//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import BrowserMessages

extension ScreenID {
  private static var counter: ScreenID = 1

  static var newScreenID: ScreenID {
    let value = Self.counter
    Self.counter += 1
    return value
  }
}

