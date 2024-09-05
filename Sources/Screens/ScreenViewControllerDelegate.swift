//
//  ScreenViewControllerDelegate.swift
//  Screens
//
//  Created by Alexey Nenastev on 5.9.24..
//
import UIKit

protocol ScreenViewControllerDelegate: AnyObject {
  func viewDidLoad()
  func viewWillAppear(_ animated: Bool)
  func viewWillDisappear(_ animated: Bool)
  func viewDidAppear(_ animated: Bool)
  func viewDidDisappear(_ animated: Bool)
}
