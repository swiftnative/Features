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
    readyToRoute = false
  }

  func viewWillDisappear(_ animated: Bool) {
    readyToRoute = false
  }

  func viewDidAppear(_ animated: Bool) {
    if appearance == nil {
      screenDidAppearFirstTime()
    } else if let appearance, appearance.appearance == .dissapeared {
      screenDidAppearAgain()
    }
    readyToRoute = true
  }

  func viewDidDisappear(_ animated: Bool) {
    readyToRoute = false
    screenDidDisappear()
  }
}
