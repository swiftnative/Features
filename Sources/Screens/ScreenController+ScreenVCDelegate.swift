//
//  ScreenController+ScreenVCDelegate.swift
//  Screens
//
//  Created by Alexey Nenastev on 5.9.24..
//
import UIKit

extension ScreenController: ScreenViewControllerDelegate {

  func viewDidLoad() {
    // Иногда происходит вызов несколько раз, пример - пуш экрана из вложенного экрана 
    guard !viewDidLoaded else { return }
    Screens.shared.screen(created: self)
    viewDidLoaded = true
  }

  func viewWillAppear(_ animated: Bool) {
    isAppearing = true
    readyToRoute = false
  }

  func viewWillDisappear(_ animated: Bool) {
    isAppearing = false
    readyToRoute = false
  }

  func viewDidAppear(_ animated: Bool) {
    isAppearing = false
    if appearance == nil {
      screenDidAppearFirstTime()
    } else if let appearance, appearance.appearance == .dissapeared {
      screenDidAppearAgain()
    }
    readyToRoute = true
  }

  func viewDidDisappear(_ animated: Bool) {
    isAppearing = false
    readyToRoute = false
    screenDidDisappear()
  }
}
