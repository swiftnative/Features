//
// Created by Alexey Nenastyev on 9.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import FeaturesDomain

protocol BrowserConnectionDelegate: AnyObject {
  func recieved(message: Message.FromBrowser)
  func connected()
  func failed(error:Error)
}

final class BrowserConnection: NSObject, URLSessionWebSocketDelegate {

  struct Config {
    let ws: URL

    static var local: Config {
      return Config(ws: URL(string: "ws://localhost:8080")!)
    }
  }

  let config: Config

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  weak var delegate: BrowserConnectionDelegate?

  private var task: URLSessionWebSocketTask?

  init(config: Config) {
    self.config = config
  }

  func start() {
    guard task?.state != .running else { return }
    task?.cancel()
    task = URLSession.shared.webSocketTask(with: config.ws)
    task?.delegate = self
    receiveNextMessage()
    task?.resume()
  }

  func stop() {
    task?.cancel()
    task = nil
  }

  func send(message: Message.ToBrowser) async {
    guard let task, task.state == .running else { return }
    do {
      let data = try encoder.encode(message)
      try await task.send(URLSessionWebSocketTask.Message.data(data))
    } catch {
      print(error)
    }
  }

  private func receiveNextMessage() {
    task?.receive { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let message):
        switch message {
        case .string(let string):
          print("Received string message: \(string)")
        case .data(let data):
          print("Received data count: \(data.count)")
          let message = try! self.decoder.decode(Message.FromBrowser.self, from: data)
          self.delegate?.recieved(message: message)
        @unknown default:
          fatalError()
        }
        self.receiveNextMessage()
      case .failure(let error):
        self.delegate?.failed(error: error)
      }
    }
  }


  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    delegate?.connected()
  }

  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    print("WebSocket connection closed with code \(closeCode.rawValue) and reason: \(String(data: reason!, encoding: .utf8)!)")
    task?.cancel()
    task = nil
  }
}
