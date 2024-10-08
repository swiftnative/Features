//
// Created by Alexey Nenastyev on 7.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI
import Combine
import Notifications
@_exported import ScreensBrowser

public final class Screens: NSObject, ObservableObject {

  private(set) var controllers = NSPointerArray.weakObjects()
  private var cancellables: Set<AnyCancellable> = []

  public static var browser: BrowserProxy? {
    get { Screens.shared.browser }
    set { Screens.shared.browser = newValue }
  }

  public static var delegate: ScreensDelegate {
    get { Screens.shared.delegate ?? Screens.shared }
    set { Screens.shared.delegate = newValue }
  }

  private(set) var browser: BrowserProxy? {
    didSet {
      browser?.delegate = self
    }
  }

  private(set) var delegate: ScreensDelegate?

  private override init() {
    super.init()
  }

  static let shared = Screens()

  public static var current: ScreenProxy { Screens.shared.current ?? ScreenController.root }

  var current: ScreenController? {

    let appeared = controllers.all()
      .filter { $0.isAppeared && $0.visibleChilds.isEmpty }

    let node = appeared
      .sorted(by: { $0.appearance!.lastAppearAt > $1.appearance!.lastAppearAt }).first

    return node
  }

  func screen(kind: ScreenEvent.Kind, for controller: ScreenController) {
    let event = ScreenEvent(id: controller.id,
                            staticID: controller.staticID,
                            kind: kind)
    screen(event: event)

    switch kind {
    case .didAppear:
      browser?.synchronize()
      if let shot = controller.screenShoot {
        browser?.send(message: .screenShoot(shot))
      }
    case .didDisappear:
      browser?.synchronize()
    default: break
    }
  }

  func screen(event: ScreenEvent) {
    browser?.send(message: .screenEvent(event))
    delegate?.event(event: event)
  }

  func screen(created controller: ScreenController) {

    controllers.add(controller)
    browser?.synchronize()
  }

  func screen(removed: ScreenID) {
    controllers.compact()
    browser?.synchronize()
  }

  func screen(set tag: ScreenTag, for screenID: ScreenID) {
    guard let controller = screen(by: screenID) else { return }
    controller.tag = tag
  }

  func screen(by id: ScreenID) -> ScreenController? {
    controllers.by(id: id)
  }

  func screen(error: String) {
    browser?.send(message: .error(error))
  }

}

extension NSPointerArray {
  func node(at index: Int) -> ScreenController? {
    guard let pointer = pointer(at: index) else { return nil }
    return Unmanaged<ScreenController>.fromOpaque(pointer).takeUnretainedValue()
  }

  func add(_ object: ScreenController) {
    addPointer(Unmanaged.passUnretained(object).toOpaque())
  }

  func all() -> [ScreenController] {
    (0..<count).compactMap { node(at: $0) }
  }

  func info() -> [ScreenControllerInfo] {
    (0..<count).compactMap { node(at: $0)?.info }
  }

  func first(where predicate: (ScreenController) -> Bool) -> ScreenController? {
    for index in 0..<self.count {
      if let obj = node(at: index), predicate(obj)  {
        return obj
      }
    }
    return nil
  }

  func by(id: ScreenID) -> ScreenController? {
    first(where: { $0.id == id })
  }
}

