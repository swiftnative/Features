//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

@Screen(alias: "Seach")
struct SearchScreen: View {
  @EnvironmentObject var app:MyMusicApp
  @Binding var searchText: String

  var screenBody: some View {
    List {
      SongListView(songs: app.all.filter { searchText.isEmpty || $0.title.lowercased().contains(searchText.lowercased(with: .current)) })
    }
  }

}

#Preview {
  SearchScreen(searchText: .constant("a"))
    .environmentObject(MyMusicApp())
}
