//
//  File.swift
//  Screens
//
//  Created by Alexey Nenastev on 22.8.24..
//

import SwiftUI

extension View {
  func push<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item : Identifiable, Content : View {
    modifier(PushViewModifier(item: item, pushContent: content))
  }
}

fileprivate struct PushViewModifier<Item: Identifiable, PushContent: View>: ViewModifier {
  @Binding var item: Item?
  @ViewBuilder var pushContent: (Item) -> PushContent

  func body(content: Content) -> some View {
    content
      .background(NavigationLink(isActive: .init(get: { item != nil }, set: { _ in item = nil})) {
          if let item  {
            pushContent(item)
          } else {
              EmptyView()
          }
      } label: {
          EmptyView()
      })
  }
}
