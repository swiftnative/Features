//
//  File 2.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//

import Foundation

public struct StackProxy: Codable, Hashable {
  public let stackID: ViewController.ID
  public let index: Int
  public let kind: Kind

  public enum Kind: String, Codable {
    case inner
    case root
    case outer
  }
  
  public init(stackID: ViewController.ID, index: Int, kind: StackProxy.Kind) {
    self.stackID = stackID
    self.index = index
    self.kind = kind
  }
}


