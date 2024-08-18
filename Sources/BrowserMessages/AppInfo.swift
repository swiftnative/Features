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
    
    if let image = getCurrentAppIcon() {
      info.logo = image.jpegData(compressionQuality: 1)
    }
    return info
  }

  static func getCurrentAppIcon() -> UIImage? {
    guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
    let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
    let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
    let lastIcon = iconFiles.last else { return nil }
    return UIImage(named: lastIcon)
  }
}
#endif

