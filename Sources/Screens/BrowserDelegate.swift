//
//  File.swift
//  Features
//
//  Created by Alexey Nenastev on 28.7.24..
//

import BrowserMessages

protocol BrowserDelegate: AnyObject {
  func recieved(message: BrowserMessage.From)
  func failed(error: Error)
  func sendState()
}
