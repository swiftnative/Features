//
//  ViewURLApp.swift
//  ViewURL
//
//  Created by Alexey Nenastev on 5.7.24..
//
import SwiftUI
import Observation
@_exported import ScreensUI

@main
struct MusicApp: App {
  @State var myMusicApp = MyMusicApp.shared
  @StateObject var browser = BrowserProxy(config: .local)

  var body: some Scene {
    WindowGroup {
      TabScreen()
        .environmentObject(myMusicApp)
        .onAppear {
          Screens.browser = browser
          browser.connect()
          Screens.delegate = self
        }
        .environmentObject(browser)
    }
  }
}


final class MyMusicApp: ObservableObject {
  var favorite: [Song] = [.aristocrat, .elPoblema, .someSong]
  var playlists: [Playlist] = [.favorite, .relax]
  var all: [Song] = .allSongs

  init() {}

  static let shared = MyMusicApp()

  var isLoggedIn: Bool = false

  func logIn() {
    isLoggedIn = true 
  }
}

final class Song: ObservableObject, Identifiable, Equatable {
  static func == (lhs: Song, rhs: Song) -> Bool {
    lhs.id == rhs.id
  }
  

  let id: Int
  let title: String
  let author: Musicant

  static let empty = Song(title: "empty", author: .init(name: ""))

  private static var id: Int = 0

  init(title: String, author: Musicant) {
    self.title = title
    self.author = author
    Song.id += 1
    self.id = Song.id
  }
}

final class Musicant: ObservableObject, Equatable {
  static func == (lhs: Musicant, rhs: Musicant) -> Bool {
    lhs.name == rhs.name
  }

  let name: String

  init(name: String) {
    self.name = name
  }
}

final class Playlist: ObservableObject, Identifiable {
  var id: String { title }
  let songs: [Song]
  let title: String
  let color: Color = .red

  init(songs: [Song], title: String) {
    self.songs = songs
    self.title = title
  }
}

