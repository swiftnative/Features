//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation

public struct ScreenState: Codable, Hashable {
  public var environemntIsPresented: Bool
  public var isPresented: Bool
  public var isAppeared: Bool
  public var lastAppeared: CFAbsoluteTime
  public var onApperPresented: Bool

  public init(
    environemntIsPresented: Bool = false,
    isPresented: Bool = false,
    isAppeared: Bool = false ,
    onApperPresented: Bool = false ) {
      self.isPresented = isPresented
      self.environemntIsPresented = environemntIsPresented
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
