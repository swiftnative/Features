//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Foundation

@Screen
public struct EmptyScreen: Equatable, ScreenURLDecodable {
  public static let path = ""
  
  public init(from params: ScreenURLParams<EmptyKeys>) throws { }

  public init() {}
  
  public var screenBody: some View {
    EmptyView()
  }
}

