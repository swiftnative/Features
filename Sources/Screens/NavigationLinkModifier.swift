//
//  NavigationLinkModifier.swift
//  Screens
//
//  Created by Alexey Nenastev on 10.9.24..
//
import SwiftUI

struct NavigationLinkModifier<Destination: View>: ViewModifier {
  @Binding var isActiveBinding: Bool
  var destination: Destination

  func body(content: Content) -> some View {
//    if #available(iOS 16.0, *), insideNavigationStack, isActiveBinding {
//      content
//        .navigationDestination(isPresented: $isActiveBinding, destination: { destination })
//    } else {
    // В табвью не рабоает navigationDestination при повторном пуше а NavigationLink работает
      content
        .background(
          NavigationLink(destination: destination, isActive: $isActiveBinding, label: EmptyView.init)
            .hidden()
        )
//    }
  }
}

extension View {
  func _navigationDestination<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(
      NavigationLinkModifier(isActiveBinding: isActive, destination: destination))
  }
}
