//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public typealias ScreenPath = String

public struct ScreenURL: Hashable, Codable, CustomStringConvertible {

  public typealias ScreenParams = [String: String]

  public let host: ScreenAction
  public let path: ScreenPath?
  public let params: ScreenParams
  public let query: ScreenAction.Params?

  public init(host: ScreenAction, path: ScreenPath? = nil, params: ScreenParams = [:], query: ScreenAction.Params? = nil) {
    self.host = host
    self.path = path
    self.params = params
    self.query = query
  }

  public init?(string: String) {
    guard let url = URL(string: string) else { return nil }
    self.init(url: url)
  }

  public init?(url: URL) {
    guard let scheme = url.scheme, scheme == "screens",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: true)  else { return nil }

    guard let host = url.host else { return nil }
    self.host = ScreenAction(host)
    self.query = components.queryParams

    guard let pathParams = components
      .path
      .removingPercentEncoding?
      .replacingOccurrences(of: "/", with: "")
      .split(separator: "["),
      let first = pathParams.first?.description else { return nil }
    self.path = first

    guard let params = pathParams
      .last?
      .replacingOccurrences(of: "]", with: "")
      .split(separator: "&") else {
      self.params = [:]
      return
    }

    self.params = params.reduce(into: [String: String]()) { result, param in
      let keyValue = param.split(separator: "=")
      guard keyValue.count == 2 else { return }
      result[String(keyValue[0])] = String(keyValue[1])
    }
  }

  public var url: URL {
    .screens(action: host.rawValue, path: path, params: params, query: query)!
  }

  public var description: String {
    url.absoluteString.removingPercentEncoding ?? url.absoluteString
  }

}

public extension ScreenURL {
  static var dismiss: Self { .init(host: .dismiss) }
}
