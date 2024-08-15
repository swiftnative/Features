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
  func push<S: Screen>(_ screen: S)
  /// Apply modifier before fullscreen
  func fullscreen<S: Screen, M: ViewModifier>(_ screen: S, modifier: M)
  /// Present Sheet
  func sheet<S: Screen, M: ViewModifier>(_ screen: S, modifier: M, configurate: (UISheetPresentationController) -> Void)
  /// Close FullScreen or Sheet
  func close()

  /// Screen environment
  var environment: EnvironmentValues { get }

  /// Set Screen environment values
  func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V)
}

public extension ScreenProxy {

  /// Present Sheet
  func sheet<S>(_ screen: S)  where S : Screen  {
    sheet(screen, modifier: EmptyModifier())
  }

  /// Present Sheet
  func sheet<S, M: ViewModifier>(_ screen: S, modifier: M)  where S : Screen  {
    sheet(screen, modifier: modifier) {
      $0.detents = [.medium(), .large()]
    }
  }
  /// Present Fullscreen
  func fullscreen<S>(_ screen: S) where S : Screen {
    fullscreen(screen, modifier: EmptyModifier())
  }
}

