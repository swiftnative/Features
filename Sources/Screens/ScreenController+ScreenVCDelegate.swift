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
    screenWillAppear()
  }

  func viewWillDisappear(_ animated: Bool) {
    guard !isDisappearing else { return }
    isDisappearing = true
    isAppearing = false
    screenWillDisappear()
  }

  func viewDidAppear(_ animated: Bool) {
    isAppearing = false
    isDisappearing = false
  }

  func viewDidDisappear(_ animated: Bool) {
    isDisappearing = false
    isAppearing = false
  }
}
