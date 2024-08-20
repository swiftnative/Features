//
// Created by Alexey Nenastyev on 31.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI

@Screen(alias: "Musicant", path: "Musician", params: "name")
struct MusicantScreen {

  let musicant: Musicant

  var screenBody: some View {
    Text(musicant.name)
      .screen(tag: musicant.name)
  }

  init(musicant: Musicant) {
    self.musicant = musicant
  }

  init(from params: Params) throws {
    self.init(musicant: Musicant(name: try params(.name)))
  }
}

#Preview {
  MusicantScreen(musicant: .maroon5)
}
