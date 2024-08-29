//
// Created by Alexey Nenastyev on 3.8.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import ScreensUI

extension MusicApp: ScreensDelegate {

  var screens: [any Screen.Type] {
    [SongView.self,
     TabScreen.self,
     LoginForm.self,
     InfoScreen.self,
     ChoseThemeScreen.self,
     SettingsView.self,
     PlaylistView.self,
     MyMusicView.self,
     LibraryView.self,
     MusicantScreen.self]
  }


  func action<S: Screen>(_ action: ScreenAction, screen: S, params: ScreenAction.Params?) {
    switch action {
    case .fullscreen:
      Screens.current.fullscreen(screen, modifier: .closeButton)
    case .sheet:
      Screens.current.sheet(screen, modifier: .detents(.medium, .large), .closeButton)
    default:
      self.default.action(action, screen: screen, params: params)
    }
  }
}
