//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import ScreensUI

struct ColorEnvironemntKey: EnvironmentKey {
  static let defaultValue: Color = .white
}

public extension EnvironmentValues {
  var color: Color {
    get { self[ColorEnvironemntKey.self] }
    set { self[ColorEnvironemntKey.self] = newValue }
  }
}

@Screen(alias: "Song", path: "song", params: "id")
struct SongView {

  @Environment(\.color) var color

  let song: Song

  public init(song: Song) {
    self.song = song
  }

  public init(id: Int)  {
    if let song = MyMusicApp.shared.all.first(where: { $0.id == id }) {
      self.song = song
    } else {
      self.song = .empty
    }
  }


  init(from params: Params) throws {
    self.init(id: try params(.id))
  }

  var screenBody: some View {
    ScreenStack {
      if song == .empty {
        Text("Song not found")
      } else {
        VStack(alignment: .leading) {
          Button {
            Screens.current.push(MusicantScreen(musicant: song.author))
          } label: {
            HStack {
              Text(song.author.name)
                .font(.title)
              Spacer()
            }
          }
          Spacer()
        }
        .padding()
        .background(color.opacity(0.2))
        .navigationTitle(song.title)
        .screenNavigationDestination
      }
    }
    .screen(tag: song.title)
  }
}

#Preview {
  VStack {
    Text("A")
    Button(action: {
      Screens.current.sheet(SongView(song: .duHast))
    }, label: {
      Text("Song")
    })
  }
    .sheet(isPresented: .constant(true)) {
      SongView(song: .duHast)
    }

}

#Preview {
  Text("A")
    .sheet(isPresented: .constant(true)) {
      SongView(id: 123232)
    }
}

extension Song {
  static var duHast = Song(title: "Du Hast", author: .ramstein)
  static var elPoblema = Song(title: "El Problems", author: .morgenstern)
  static var aristocrat = Song(title: "Aristocrat", author: .morgenstern)
  static var someSong = Song(title: "SomeSong", author: .maroon5)
}

extension Musicant {
  static var morgenstern = Musicant(name: "Morgenstern")
  static var maroon5 = Musicant(name: "Maroon5")
  static var ramstein = Musicant(name: "Ramstein")
}

extension [Song] {
  static var allSongs: [Song] {
    return [.duHast, .elPoblema, .aristocrat, .someSong]
  }
}

extension String: Error {}
