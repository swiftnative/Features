//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import Foundation
import UIKit
import SwiftUI

public protocol ScreenProxy {
  /// Equal to Envronment(\.dismiss), one step back in stack or dismiss presented view
  func dismiss()
  /// Push to NavaigationController
  func push<S: Screen, M: ViewModifier>(_ screen: S, modifier: M)
  /// Apply modifier before fullscreen
  func fullscreen<S: Screen, M: ViewModifier>(_ screen: S, modifier: M)
  /// Present Sheet
  func sheet<S: Screen, M: ViewModifier>(_ screen: S, modifier: M)
  /// Close FullScreen or Sheet
  func close()

}

public extension ScreenProxy {

  /// Present Sheet
  func sheet<S>(_ screen: S)  where S : Screen  {
    sheet(screen, modifier: EmptyModifier())
  }

  /// Present Sheet
  func sheet<S, M: ViewModifier>(_ screen: S, modifier: M)  where S : Screen  {
    sheet(screen, modifier: modifier)
  }
  /// Present Fullscreen
  func fullscreen<S>(_ screen: S) where S : Screen {
    fullscreen(screen, modifier: EmptyModifier())
  }

  /// Push
  func push<S>(_ screen: S) where S : Screen {
    push(screen, modifier: EmptyModifier())
  }
}

