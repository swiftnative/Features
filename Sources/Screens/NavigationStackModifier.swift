//
// Created by Alexey Nenastyev on 17.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import Notifications
import SwiftUI
import ScreensBrowser

extension Notification {
  struct PushScreenNotification: PayloadNotification {
    let screen: AnyView
    let kind: StackKind
    let stackHolder: ScreenID
    typealias Payload = Self
  }
}


struct NavigationStackModifier: ViewModifier {
    @State var pushed: Notification.PushScreenNotification?
    @Environment(\.screenID) var screenID
    let kind: StackKind

    func body(content: Content) -> some View {
        content
        .onReceive(Notification.PushScreenNotification.publisher) { notification in
          guard screenID == notification.stackHolder && kind == notification.kind else { return }
          pushed = notification
        }
        .background(NavigationLink(isActive: $pushed.mappedToBool()) {
          if let view = pushed?.screen {
                view
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        })
    }
}

public extension Binding where Value == Bool {
    init<Wrapped>(bindingOptional: Binding<Wrapped?>) {
        self.init(
            get: {
                bindingOptional.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }

                /// We only handle `false` booleans to set our optional to `nil`
                /// as we can't handle `true` for restoring the previous value.
                bindingOptional.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    public func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}


public extension View {
  var screenNavigationDestination: some View {
    modifier(NavigationStackModifier(kind: .inner))
      .preference(key: ScreenNavigationDestinationPreferenceKey.self, value: true)
  }

  func screenStack() -> some View {
    EmptyView()
      .modifier(NavigationStackModifier(kind: .inner))
      .preference(key: ScreenNavigationDestinationPreferenceKey.self, value: true)
  }
}

struct ScreenNavigationDestinationPreferenceKey: PreferenceKey {
  static var defaultValue = false

  static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}

