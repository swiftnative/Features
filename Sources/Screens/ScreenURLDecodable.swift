//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


public protocol ScreenURLDecodable: Screen {
  associatedtype ParamsKey: RawRepresentable<String>
  static var path: ScreenPath { get }
  typealias Params = ScreenURLParams<ParamsKey>
  init(from params: Params) throws
}

public struct ScreenURLParams<Keys: RawRepresentable<String>> {

  let params: [String: String]

  init(params: [String: String]) {
    self.params = params
  }

  public func callAsFunction<T>(_ key: Keys) throws -> T where T: ThrowableStringConvertible {
    guard let value = params[key.rawValue] else { throw ConversionError.noValue(forKey: key.rawValue) }
    return try T(from: value)
  }

  public func callAsFunction<T>(_ key: Keys) -> T? where T: LosslessStringConvertible {
    guard let value = params[key.rawValue] else { return nil}
    return T(value)
  }
}

public struct EmptyKeys: RawRepresentable {
  public init?(rawValue: String) { nil }
  public var rawValue: String = ""
}
