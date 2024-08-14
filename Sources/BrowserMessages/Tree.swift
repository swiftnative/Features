//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation

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
