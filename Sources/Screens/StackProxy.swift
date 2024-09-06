//
//  StackProxyInfo.swift
//  Screens
//
//  Created by Alexey Nenastev on 7.9.24..
//
import UIKit
import ScreensBrowser

public struct StackProxy: Equatable {
  public static func == (lhs: StackProxy, rhs: StackProxy) -> Bool {
    lhs.stackID == rhs.stackID &&
    lhs.index == rhs.index &&
    lhs.kind == rhs.kind
  }

  public let stackID: ViewController.ID
  public let index: Int
  public let kind: Kind
  let controller: WeakRef<UIViewController>

  public enum Kind: String, Codable {
    case inner
    case root
    case outer
  }

  init(nc: UINavigationController, index: Int, kind: StackProxy.Kind) {
    self.stackID = nc.vcID
    self.controller = WeakRef(nc)
    self.index = index
    self.kind = kind
  }
}

extension StackProxy {
  var info: StackProxyInfo {
    .init(stackID: stackID, index: index, kind: kindInfo)
  }

  var kindInfo: StackProxyInfo.Kind {
    switch kind {
    case .inner: return .inner
    case .root: return .root
    case .outer: return .outer
    }
  }
}
