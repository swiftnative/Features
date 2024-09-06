//
//  WeakRef.swift
//  Screens
//
//  Created by Alexey Nenastev on 7.9.24..
//


public final class WeakRef<T:AnyObject> {
  private weak var value: T?
  
  public init(_ value: T) {
    self.value = value
  }
}