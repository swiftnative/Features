//
//  SwiftUITestAppear.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 11.9.24..
//

import SwiftUI

@Screen
struct SwiftUIOnAppear {
  @State var isPresented: Bool = false

  var screenBody: some View {
    Button("OnAppearTest") {
      isPresented.toggle()
    }
    .fullScreenCover(isPresented: $isPresented) {
      if #available(iOS 16.0, *) {
        NavigationStack {
          SwiftUIDog()
        }
      }
    }
  }
}

@Screen
struct SwiftUIDog: View {
  @State var isPresented: Bool = false

  var screenBody: some View {
    Text("Dog")
      .background(
        NavigationLink(destination: SwiftUICat(), isActive: $isPresented, label: EmptyView.init)
          .hidden()
      )
      .onAppear {
        print("Dog!!!")
        isPresented = true
      }
  }
}

@Screen
struct SwiftUICat: View {
  var screenBody: some View {
    Text("Cat")
  }
}
