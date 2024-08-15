//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

@Screen(alias: "Playlist")
struct PlaylistView {
  let playlist: Playlist

  var screenBody: some View {
    VStack(alignment: .leading) {
      Text("\(playlist.songs.count) songs")
        .padding()
      List {
        SongListView(songs: playlist.songs)
      }
    }
    .navigationTitle(playlist.title)
  }
}

#Preview {
  NavigationView {
    PlaylistView(playlist: .favorite)
  }
}

extension Playlist {
  static var favorite = Playlist(songs: [Song.someSong, Song.duHast], title: "Favorite")
  static var relax = Playlist(songs: [Song.elPoblema, Song.aristocrat, Song.someSong], title: "Morgenstern")
}
