//
//  ScreenController+ScreenVCDelegate.swift
//  Screens
//
//  Created by Alexey Nenastev on 5.9.24..
//


extension ScreenController: ScreenViewControllerDelegate {

  func viewDidLoad() {
    guard didLoad == false else { return }
    Screens.shared.screen(created: self)
    didLoad = true
  }

  func viewWillAppear(_ animated: Bool) {
    isAppearing = true
    /// isDisappearing  - its case when cancel swipe gesture for poping back in stack
    if appearance.isFirstAppearance || isDisappearing  {
      screenDidAppear()
    }
  }

  func viewWillDisappear(_ animated: Bool) {
    isDisappearing = true
    notifyPreviousScreensToBePoped()
  }

  func viewDidAppear(_ animated: Bool) {
    isAppearing = false
    isDisappearing = false
  }

  func viewDidDisappear(_ animated: Bool) {
    isDisappearing = false
    isAppearing = false
    Screens.shared.screen(stateUpdated: self)
  }
}
