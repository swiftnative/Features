//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation

public struct ScreenState: Codable, Hashable {
  public var isPresented: Bool
  public var isAppeared: Bool {
    didSet {
      guard isAppeared else { return }
      lastAppeared = CFAbsoluteTimeGetCurrent()
    }
  }

  public var lastAppeared: CFAbsoluteTime
  public var onApperPresented: Bool

  public init(
    isPresented: Bool = false,
    isAppeared: Bool = false ,
    onApperPresented: Bool = false) {
      self.isPresented = isPresented
      self.isAppeared = isAppeared
      self.onApperPresented = onApperPresented
      self.lastAppeared = CFAbsoluteTimeGetCurrent()
    }
}

extension ScreenState: CustomDebugStringConvertible {
  public var debugDescription: String {
    "p:\(isPresented) a:\(isAppeared)"
  }
}
