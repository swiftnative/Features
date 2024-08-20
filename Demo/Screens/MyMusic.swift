//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import ScreensUI

@Screen(alias: "MyMusic")
struct MyMusicView {
  @Environment(MyMusicApp.self) var app
  @State var loginPresented: Bool = false

  init() {}

  var screenBody: some View {
    NavigationView {
      VStack {
        if !app.isLoggedIn {
          Text("Login to see Your Music")
          Button("Login") {
            loginPresented.toggle()
          }
        } else {
          List {
            Section("Favorites") {
              SongListView(songs: app.favorite)
            }
            
            Section("Playlist") {
              ForEach(app.playlists) { playlist in
                NavigationLink {
                  PlaylistView(playlist: playlist)
                } label: {
                  HStack {
                    Image(systemName: "music.quarternote.3")
                    Text(playlist.title)
                  }
                }
              }
            }
          }
        }
      }
      .sheet(isPresented: $loginPresented) {
        LoginForm()
          .presentationDetents([.medium])
      }
    }
  }
}

#Preview {
  MyMusicView()
    .environment(MyMusicApp())
}
