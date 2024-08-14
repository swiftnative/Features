//
//  ContentView.swift
//  ViewURL
//
//  Created by Alexey Nenastev on 5.7.24..
//

import SwiftUI
import Features

@Screen(alias: "Library")
struct LibraryView {

  @Environment(MyMusicApp.self) var app
  @State var searchText = ""
  @State var nativeSheet = false

  var screenBody: some View {
    NavigationView {
      if searchText.isEmpty {
        List {
          NavigationLink("Info") {
            InfoScreen()
          }

          Button("fullscreen") {
            Screens.current.fullscreen(InfoScreen(), modifier: .closeButton)
          }

          Button("fullscreen-action") {
            Screens.action(.fullscreen, screen: InfoScreen())
          }

          Button("Sheet-Info") {
            Screens.current.sheet(InfoScreen(), modifier: .closeButton)
          }

          Button("Sheet-Song") {
            Screens.current.sheet(SongView(song: .duHast), modifier: .closeButton)
          }
          Button("Native Sheet") {
            nativeSheet.toggle()
          }

          Section("Green") {
            SongListView(songs: [.duHast, .someSong])
          }
          .environment(\.color, .green)

          Section("Red") {
            SongListView(songs: [.elPoblema])
          }
          .environment(\.color, .red)

          Section("Blue") {
            SongListView(songs: app.all.filter { $0.author == .morgenstern })
          }
          .environment(\.color, .blue)
        }
        .searchable(text: $searchText, prompt: "Search")
        .sheet(isPresented: $nativeSheet, content: {
          SongView(song: .duHast)
        })
      } else {
        SearchScreen(searchText: $searchText)
      }
    }

  }
}

#Preview {
  LibraryView()
    .environment(MyMusicApp())
}