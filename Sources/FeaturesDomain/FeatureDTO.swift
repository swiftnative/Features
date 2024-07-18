//
// Created by Alexey Nenastyev on 15.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation


#if canImport(UIKit)
import UIKit
public extension ApplicationInfo {
  static var current: ApplicationInfo {
    var info = ApplicationInfo()

    info.bundleID = Bundle.main.bundleIdentifier ?? ""
    info.name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    let image = UIImage(systemName: "wifi")
    info.logo = image?.jpegData(compressionQuality: 1)
    return info
  }
}
#endif

public struct NodeStackInfo: Codable, Hashable {
  public let stackID: String
  public let index: Int

  public init(stackID: String, index: Int) {
    self.stackID = stackID
    self.index = index
  }
}

public struct FeatureState: Codable, Hashable {
  public var isPresented: Bool
  public var isAppeared: Bool
  public var onApperPresented: Bool

  public init(isPresented: Bool = false,
              isAppeared: Bool = false ,
              onApperPresented: Bool = false ) {
    self.isPresented = isPresented
    self.isAppeared = isAppeared
    self.onApperPresented = onApperPresented
  }
}

extension FeatureState: CustomDebugStringConvertible {
  public var debugDescription: String {
    "p:\(isPresented) a:\(isAppeared)"
  }
}

public struct FeatureDTO: Hashable, Codable {
  public typealias ID = UUID
  public let nodeID: ID
  public let featureID: String
  public let type: String
  public let parentNodeID: ID?
  public let state: FeatureState
  public let file: String
  public let stack: NodeStackInfo?
  public let vcHierarhyInfo: [String]
  public let info: String

  public init(id: UUID, featureID: String, type: String, parentNodeID: UUID?, state: FeatureState, file: String, stack: NodeStackInfo?, vcHierarhyInfo: [String], info: String) {
    self.nodeID = id
    self.featureID = featureID
    self.type = type
    self.parentNodeID = parentNodeID
    self.state = state
    self.file = file
    self.stack = stack
    self.vcHierarhyInfo = vcHierarhyInfo
    self.info = info
  }
}

public struct ApplicationInfo: Codable {
  public var name: String
  public var bundleID: String
  public var logo: Data?

  public init(name: String = "", bundleID: String = "", logo: Data? = nil) {
    self.name = name
    self.bundleID = bundleID
    self.logo = logo
  }
}

public enum Message {

  public enum ToBrowser: Codable {
    case featureTree([FeatureDTO])
    case appInfo(ApplicationInfo)
    case featureImage(FeatureImage)
    case nodeInfo(info: FeatureDTO)
    case vcTree([Tree<ViewController>])
  }

  public enum FromBrowser: Codable {
    case dismiss(nodeID: FeatureDTO.ID)
    case getInfo(nodeID: FeatureDTO.ID)
  }
}

public enum FeatureEvent {
  case viewDidAppear, viewDidDisappear
  case moveToParent
}

public struct FeatureImage: Codable {
  public let data: Data
  public let nodeID: UUID
}

extension Message.FromBrowser: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case let .dismiss(nodeID): "<- dismiss \(nodeID)"
    case let .getInfo(nodeID): "<- getInfo \(nodeID)"
    }
  }
}

extension Message.ToBrowser: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .featureTree: "-> actualTree"
    case .vcTree: "-> vcTree"
    case let .appInfo(info): "-> appInfo \(info.name) \(info.bundleID)"
    case .featureImage:  "-> featureImage"
    case let .nodeInfo(info): "-> node info featureID: \(info.featureID)"
    }
  }
}

public struct ViewController: Codable, Hashable {

//  public static func == (lhs: ViewController, rhs: ViewController) -> Bool {
//    lhs.id == rhs.id
//  }
//
//  public func hash(into hasher: inout Hasher) {
//    hasher.combine(id)
//    hasher.combine(type)
//    hasher.combine(featureID)
//    hasher.combine(address)
//    hasher.combine(parentID)
//  }

  public typealias ID = String
  public let id: ID
  public let type: String
  public let featureID: String?
  public let featureNodeID: UUID?
  public let address: String
  public let parentID: ID?

  public var isFeatureController: Bool { featureID != nil }

  public init(id: ID, type: String, featureID: String? = nil, featureNodeID: UUID? = nil, address: String, parentID: ID? = nil) {
    self.id = id
    self.type = type
    self.featureID = featureID
    self.featureNodeID = featureNodeID
    self.address = address
    self.parentID = parentID
  }
}

public extension ViewController {
  static var root = ViewController(id: "Root", type: "Root", address: "root", parentID: nil)
}

public final class Tree<Value: Hashable>: Hashable, Codable where Value: Codable {
  
  public static func == (lhs: Tree<Value>, rhs: Tree<Value>) -> Bool {
    lhs.value == rhs.value && lhs.children == rhs.children
  }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(value)
      hasher.combine(children)
    }

  public let value: Value
  public var children: [Tree]?

  public init(value: Value, children: [Tree]? = nil) {
    self.value = value
    self.children = children
  }

  public func first(where predicate: (Value) -> Bool) -> Tree? {
    if predicate(value) {
      return self
    }
    guard let children else { return nil }

    for tree in children {
      if let matchingChild = tree.first(where: predicate) {
        return matchingChild
      }
    }
    return nil
  }
}


public extension UUID {
  static var zero = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}
