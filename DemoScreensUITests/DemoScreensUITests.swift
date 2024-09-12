//
//  DemoScreensUITests.swift
//  DemoScreensUITests
//
//  Created by Alexey Nenastev on 25.8.24..
//

import XCTest
import SwiftUI
@testable import DemoScreens

final class DemoScreensUITests: XCTestCase {
  private var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()

 }

  override func tearDownWithError() throws {
    app = nil
  }

  func testFullscreen() throws {
    app.buttons["FullScreen"].tap()
    XCTAssertTrue(app.staticTexts["Dog"].waitForExistence(timeout: 0.5))
    app.buttons["Dismiss"].tap()
    XCTAssertTrue(app.staticTexts["Screens"].waitForExistence(timeout: 0.5))
  }

  func testFullscreen2() throws {
    app.buttons["FullScreen"].tap()
    XCTAssertTrue(app.staticTexts["Dog"].waitForExistence(timeout: 0.5))
    app.buttons["Dismiss"].tap()
    XCTAssertTrue(app.staticTexts["Screens"].waitForExistence(timeout: 0.5))
  }

  func testA() throws {
    
  }
}

extension XCUIApplication {
  var screenTitle: String {
    staticTexts["screen-title"].title
  }

//  var isTestsScreen: Bool {
//    app.scrollViews["tests"]
//  }
}
