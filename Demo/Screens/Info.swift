//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

@Screen(path: "info")
struct InfoScreen: View {
  @Environment(\.color) var color
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var app: MyMusicApp

  var screenBody: some View {
    ZStack {
      color.opacity(0.2).ignoresSafeArea()
      VStack {
        Button("dismiss") {
          dismiss()
        }
        if #available(iOS 16.0, *) {
          LabeledContent("All", value: app.all.count, format: .number)
          LabeledContent("Favorites", value: app.favorite.count, format: .number)
          LabeledContent("Playlists", value: app.playlists.count, format: .number)
        }
      }
      .padding()
    }
  }

  init() {}

  init(from params: Params) throws {
  }
}

#Preview {
  InfoScreen()
    .environmentObject(MyMusicApp())
}
