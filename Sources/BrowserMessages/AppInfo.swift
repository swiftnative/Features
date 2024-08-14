//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation

public typealias AppID = String

public struct AppInfo: Codable, Equatable, Identifiable, CustomStringConvertible {
  public var id: AppID { bundleID }
  public var name: String
  public var bundleID: String
  public var logo: Data?

  public var description: String {
    id
  }

  public init(name: String = "", bundleID: String = "", logo: Data? = nil) {
    self.name = name
    self.bundleID = bundleID
    self.logo = logo
  }
}

#if canImport(UIKit)
import UIKit
public extension AppInfo {
  static var current: AppInfo {
    var info = AppInfo()

    info.bundleID = Bundle.main.bundleIdentifier ?? ""
    info.name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    let image = UIImage(systemName: "wifi")
    info.logo = image?.jpegData(compressionQuality: 1)
    return info
  }
}
#endif

