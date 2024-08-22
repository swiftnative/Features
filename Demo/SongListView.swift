//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import UIKit

struct SongListView: View {
  @Environment(\.color) var color
  var songs: [Song]
  @State var isPresented: Bool = false

  @State var color2: Color?

  var body: some View {
    ForEach(songs) { song in
      Button(song.author.name + " - " + song.title, systemImage: "music.note") {
        Screens.current.sheet(SongView(song: song), modifier: .closeButton)
      }
    }
  }
}

#Preview {
  SongListView(songs: [.aristocrat, .duHast])
}
