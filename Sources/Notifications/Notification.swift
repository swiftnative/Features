//
// Created by Alexey Nenastyev on 2.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import NotificationCenter
import Combine
import os
import SwiftUI

public protocol PayloadNotification {
  associatedtype Payload
}


public extension PayloadNotification {
  internal static var id: ObjectIdentifier { ObjectIdentifier(Self.self) }
  internal static var name: Notification.Name { Notification.Name(id.debugDescription) }

  static func subscribe(receiveValue: @escaping (Payload) -> Void) -> AnyCancellable {
    publisher
    .sink(receiveValue: receiveValue)
  }

  static var publisher: AnyPublisher<Payload, Never> {
    NotificationCenter.default.publisher(for: name, object: nil).compactMap { notification in
      notification.payload(forType: Self.self)
    }.eraseToAnyPublisher()
  }

  static func post(_ payload: Payload) {
    NotificationCenter.default.post(name: name, object: nil, userInfo: [id: payload])
  }

  static func post() where Payload == Void {
    NotificationCenter.default.post(name: name, object: nil)
  }
}

fileprivate extension Notification {
  func payload<E>(forType type: E.Type) -> E.Payload? where E: PayloadNotification {
    guard self.name == type.name else { return nil }

    guard let userInfo = self.userInfo else {
      assertionFailure("userInfo can't be nil for notification event \(type)")
      return nil
    }

    guard let value = userInfo[type.id], let payload = value as? E.Payload  else {
      assertionFailure("payload for notification event \(type) should exist")
      return nil
    }
    return payload
  }
}

func log(_ message: String) {
  Notification.Log.post(message)
}

// MARK: Public Extensions

public extension Notification.Name {
  func subscribe(receiveValue: @escaping (Notification) -> Void) -> AnyCancellable {
    NotificationCenter.default.publisher(for: self, object: nil).sink(receiveValue: receiveValue)
  }

  func onRecieve(_ receiveValue: @escaping (Notification) -> Void) -> NSObjectProtocol {
    NotificationCenter.default.addObserver(
      forName: self,
      object: nil,
      queue: nil,
      using: receiveValue
    )
  }

  var publisher: NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: self, object: nil)
  }

  func post() {
    NotificationCenter.default.post(self)
  }

  func recieve<Obj>(on instance: Obj, call: @escaping (Obj) -> () -> Void) -> AnyCancellable where Obj: AnyObject {
    subscribe(receiveValue: { [weak instance] _ in
       guard let instance = instance else { return }

       let instanceFunc = call(instance)
       instanceFunc()
    })
  }
}

public extension NotificationCenter {
  func post(_ name: Notification.Name) {
    post(name: name, object: nil)
  }
}

public extension PayloadNotification {
  static func recieve<Obj>(on instance: Obj, call: @escaping (Obj) -> (Payload) -> Void) -> AnyCancellable where Obj: AnyObject {
    subscribe(receiveValue: withWeak(instance, call: call))
  }
}

extension View {
  func onRecieve<P: PayloadNotification>(_ notification: P.Type, perform action: @escaping (P.Payload) -> Void) -> some View {
    onReceive(notification.publisher, perform: action)
  }
}


extension Notification {
    struct Log: PayloadNotification {
      typealias Payload = String
    }
}

