////
//// Created by Alexey Nenastyev on 2.8.24.
//// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.
//
//
//import Foundation
//import SwiftUI
//import ScreensBrowser
//import Notifications
//
//public typealias ScreenState = String
//public typealias ScreenStateKey = String
//
//struct ScreenStateModifier: ViewModifier {
//  @Environment(\.screenID) var screenID
//  let key: ScreenStateKey
//  @Binding var state: ScreenState
//
//  func body(content: Content) -> some View {
//    content
////      .onReceive(NotificationCenter.default.publisher(for: .screenState(key: key)), perform: { notification in
////        
////      }
////      .task {
////        Screens.shared.screen(set: tag, for: screenID)
////      }
//  }
//}
//
//public extension View {
//  func screen(state key: ScreenStateKey, _ value: Binding<ScreenState>) -> some View {
//    modifier(ScreenStateModifier(key: key, state: value))
//  }
//}
//
//extension Notification{
//  struct ScreenState: PayloadNotification {
//    let key: ScreenStateKey
//  }
//}
