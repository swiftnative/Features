//
// Created by Alexey Nenastyev on 18.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ScreenShoot: Codable {
  public let screenID: ScreenID
  public let data: Data

  public init(screenID: ScreenID, data: Data) {
    self.screenID = screenID
    self.data = data
  }
}
