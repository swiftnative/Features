//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

@Screen(alias: "Login", path: "login")
struct LoginForm: View {
  @Environment(MyMusicApp.self) var app

  var screenBody: some View {
    ZStack {
      Color.white
        .edgesIgnoringSafeArea(.all)
      Button("Login") {
        app.logIn()
        Screens.current.close()
      }
      .buttonStyle(.bordered)
    }
    .modifier(.closeButton)
  }

  init() {  }
  init(from params: Params) throws { }
}

#Preview {
  LoginForm()
    .environment(MyMusicApp())
}
