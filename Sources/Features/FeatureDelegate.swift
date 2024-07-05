//
// Created by Alexey Nenastyev on 5.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os

public protocol FeatureDelegateType {
  func onAppear(_ feature: String, file: StaticString)
  func onDisappear(_ feature: String, file: StaticString)
}

public extension FeatureDelegateType {
  func onAppear(_ feature: String, file: StaticString) {
  }

  func onDisappear(_ feature: String, file: StaticString) {
  }
}

public final class FeatureDelegate: FeatureDelegateType {
  private init() {}
  public static var logger: Logger? = Logger(subsystem: "features", category: "features")
  public static var current: FeatureDelegateType?
}
