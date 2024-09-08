//
// Created by Alexey Nenastyev on 9.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import ScreensBrowser

public final class BrowserProxy: NSObject, ObservableObject {

  public struct Config {
    let ws: URL

    public static var local = Config(ws: URL(string: "ws://localhost:8080")!)

    public init(ws: URL) {
      self.ws = ws
    }
  }

  public var isConnected: Bool { state == .running }
  public var state: URLSessionTask.State? { task?.state }
  let config: Config

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  weak var delegate: BrowserDelegate?


  private var syncTimer: Timer?
  private var task: URLSessionWebSocketTask?

  public init(config: Config) {
    self.config = config
  }

  public func connect() {
    guard task?.state != .running else { return }
    task?.cancel()
    task = URLSession.shared.webSocketTask(with: config.ws)
    task?.delegate = self
    receiveNextMessage()
    task?.resume()
    objectWillChange.send()
  }

  public func disconnect() {
    task?.cancel()
    task = nil
    objectWillChange.send()
  }

  public func synchronize() {
    syncTimer?.invalidate()

    syncTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [weak self] (timer) in
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        self?.delegate?.sendState()
      }
    })
  }

  func send(message: BrowserMessage.To) {
    guard let task, task.state == .running else { return }
    Task {
      do {
        let data = try encoder.encode(message)
        try await task.send(URLSessionWebSocketTask.Message.data(data))
      } catch {
        print(error)
        objectWillChange.send()
      }
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
          do {
            let message = try self.decoder.decode(BrowserMessage.From.self, from: data)
            self.delegate?.recieved(message: message)
          } catch {
            print("Error decoding message: \(error)")
          }
        @unknown default:
          fatalError()
        }
        self.receiveNextMessage()
      case .failure(let error):
        self.delegate?.failed(error: error)
      }
    }
  }

  private func onConnected() {
    Task { @MainActor in
      objectWillChange.send()
    }
  }
}

extension BrowserProxy: URLSessionWebSocketDelegate {
  public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    onConnected()
  }

  public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    print("WebSocket connection closed with code \(closeCode.rawValue) and reason: \(String(data: reason!, encoding: .utf8)!)")
    task?.cancel()
    task = nil
    objectWillChange.send()
  }
}
