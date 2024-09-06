//
//  ContentView.swift
//  ViewURL
//
//  Created by Alexey Nenastev on 5.7.24..
//

import SwiftUI
import ScreensUI

@Screen(alias: "Library")
struct LibraryView {

  @EnvironmentObject var app: MyMusicApp
  @State var searchText = ""
  @State var nativeSheet = false

  var screenBody: some View {
    ScreenStack {
      Group {
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
            
            NavigationLink("Song") {
              SongView(song: .duHast)
            }
            
            Button("Push-Song") {
              Screens.current.push(SongView(song: .duHast))
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
      .onAppear {
        print("Library appear current: \(Screens.current)")
      }
    }
  }
}

#Preview {
  LibraryView()
    .environmentObject(MyMusicApp())
}
