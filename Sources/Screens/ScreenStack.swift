//
//  ScreenStack.swift
//  Features
//
//  Created by Alexey Nenastev on 17.8.24..
//

import Foundation
import SwiftUI

public struct ScreenStack<Root: View>: View {

  let root: () -> Root

  public init(@ViewBuilder root: @escaping () -> Root) {
    self.root = root
  }

  public var body: some View {
    if #available(iOS 16.0, *) {
      NavigationStack {
        root()
          .screenNavigationDestination
      }
    } else {
      NavigationView {
        root()
          .screenNavigationDestination
      }
    }
  }
}
