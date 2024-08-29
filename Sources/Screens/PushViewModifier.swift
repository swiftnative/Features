//
//  File.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//

import SwiftUI

extension View {
  func push<Content>(item: Binding<ScreenAppearRequest?>, @ViewBuilder content: @escaping (ScreenAppearRequest) -> Content) -> some View where Content : View {
//    Group {
//      if #available(iOS 17.0, *) {
//        modifier(PushViewModifierStack(item: item, pushContent: content))
//      } else {
        modifier(PushViewModifier(item: item, pushContent: content))
//      }
//    }
  }
}


@available(iOS 17.0, *)
public struct PushViewModifierStack<PushContent: View>: ViewModifier {
  @Binding var item: ScreenAppearRequest?
  @ViewBuilder var pushContent: (ScreenAppearRequest) -> PushContent

  public init(item: Binding<ScreenAppearRequest?>,
              @ViewBuilder pushContent: @escaping (ScreenAppearRequest) -> PushContent) {
    self._item = item
    self.pushContent = pushContent
  }

  public func body(content: Content) -> some View {
    content
      .navigationDestination(item: $item, destination: pushContent)
  }
}

fileprivate struct PushViewModifier<PushContent: View>: ViewModifier {
  @Binding var item: ScreenAppearRequest?
  @ViewBuilder var pushContent: (ScreenAppearRequest) -> PushContent
  @State var presented: Bool = false

  func body(content: Content) -> some View {
    content
      .onChange(of: presented, perform: { newValue in
        if newValue == false {
          item = nil
        }
      })
      .onChange(of: item, perform: { newValue in
        presented = item != nil
      })
      .onAppear {
        presented = item != nil
      }
      .background(NavigationLink(isActive: $presented) {
          if let item {
            pushContent(item)
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
