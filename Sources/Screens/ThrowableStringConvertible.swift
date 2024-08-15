//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public protocol ThrowableStringConvertible {
  init(from string: String) throws
}

enum ConversionError: Error, CustomStringConvertible {
  case invalidFormat(type: String, value: String)
  case noValue(forKey: String)

  var description: String {
    switch self {
    case let .invalidFormat(type, value):
      return "Can't convert string '\(value)' to \(type)"
    case .noValue(forKey: let key):
      return "No value for key: \(key)"
    }
  }
}

extension Int: ThrowableStringConvertible {
  public init(from string: String) throws {
    guard let value = Int(string) else {
      throw ConversionError.invalidFormat(type: "Int", value: string)
    }
    self = value
  }
}

extension Double: ThrowableStringConvertible {
  public init(from string: String) throws {
    guard let value = Double(string) else {
      throw ConversionError.invalidFormat(type: "Double", value: string)
    }
    self = value
  }
}

extension Bool: ThrowableStringConvertible {
  public init(from string: String) throws {
    guard let value = Bool(string) else {
      throw ConversionError.invalidFormat(type: "Bool", value: string)
    }
    self = value
  }
}

extension String: ThrowableStringConvertible {
  public init(from string: String) throws {
    self = string
  }
}
