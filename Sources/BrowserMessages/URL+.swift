//
// Created by Alexey Nenastyev on 5.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public extension URL {
  static func screens(action: String, path: String?, params: [String: String]?, query: [String: String]?) -> URL? {
    let queryItems = query?.map { URLQueryItem(name: $0.key, value: $0.value) }
    let pathParams =  params?.map { URLQueryItem(name: $0.key, value: $0.value).description }.joined(separator: "&")

    var components = URLComponents()
    components.scheme = "screens"
    components.host = action
    if let path, let pathParams {
      components.path = "/\(path)" + (pathParams.isEmpty ? "" : "[\(pathParams)]")
    }
    components.queryItems = queryItems
    return components.url
  }
}

public extension URLComponents {
  var queryParams: [String: String]? {
    guard let queryItems else { return nil }
    var queryDict = [String: String]()
       for item in queryItems {
           if let value = item.value {
               queryDict[item.name] = value
           }
       }
    return queryDict
  }
}
