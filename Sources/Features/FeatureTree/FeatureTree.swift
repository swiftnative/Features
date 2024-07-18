//
// Created by Alexey Nenastyev on 7.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import SwiftUI
import FeaturesDomain

public final class FeatureTree: ObservableObject {

  private var nodes = NSPointerArray.weakObjects()
  private var syncTimer: Timer?
//  private let root = FeatureNode.root
  var browserConnection: BrowserConnection? = BrowserConnection(config: .local) {
    didSet {
      browserConnection?.delegate = self
    }
  }

  init() {
//    root.state.isAppeared = true
//    nodes.add(root)
  }

  public static let shared = FeatureTree()

  func nodeCreated(node: FeatureNode) {
    nodes.add(node)
    //    print("created |" + String(reflecting: node))
    syncRemote()
  }

  func nodeRemoved(node: FeatureNode.ID) {
    nodes.compact()
    syncRemote()
  }



  func nodeStateUpdated(node: FeatureNode) {
    //    print("updated |" + String(reflecting: node))
    syncRemote()
  }


  public func syncRemote() {
    guard browserConnection != nil else { return }

    self.syncTimer?.invalidate()

    syncTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { [weak self] (timer) in
      DispatchQueue.global(qos: .userInteractive).async { [weak self] in
        self?.sendActualTree()
        self?.sendVCTree()
      }
    })
  }

  public func connect() {
    browserConnection?.delegate = self
    browserConnection?.start()
  }

  public func disconnect() {
    browserConnection?.stop()
  }

  public func sendActualTree() {
    let dtos = nodes.dto()
    send(.featureTree(dtos))
  }

  func sendVCTree() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      let tree = self.vcTree()
      self.send(.vcTree(tree))
    }
  }

  @MainActor
  private func vcTree() -> [Tree<ViewController>] {

    var dict: [ViewController.ID: Tree<ViewController>] = [:]
    var result: [Tree<ViewController>] = []

    func scan(uiVC: UIViewController, child: Tree<ViewController>? = nil) {
      let vc = uiVC.vc

      if let node = dict[vc.id] {
        if let child {
          if node.children == nil {
            node.children = [child]
          } else {
            node.children!.append(child)
          }
        }
      } else {
        let node = Tree(value: vc)
        if let child {
          node.children = [child]
        }
        dict[vc.id] = node
        if let parent = uiVC.parent {
          scan(uiVC: parent, child: node)
        } else {
          result.append(node)
        }
      }
    }

    let nodes = nodes.all()

    nodes.forEach {
        scan(uiVC: $0, child: nil)
      }

    return result
  }

  private func send(_ message: Message.ToBrowser) {
    guard let browserConnection else { return }
    Task {
      await browserConnection.send(message: message)
    }
  }

  @MainActor
  func dismissNode(nodeID: FeatureNode.ID) {
    guard let node = nodes.by(nodeID: nodeID) else { return }
    node.dismiss?()
  }

  @MainActor
  func getInfo(nodeID: FeatureNode.ID) {
    guard let node = nodes.by(nodeID: nodeID) else { return }
    node.update()
    send(.nodeInfo(info: node.dto))
  }


}

extension FeatureTree: BrowserConnectionDelegate {
  func recieved(message: Message.FromBrowser) {
    Task { @MainActor in
      switch message {
      case let .dismiss(nodeID):
        dismissNode(nodeID: nodeID)
      case .getInfo(nodeID: let nodeID):
        getInfo(nodeID: nodeID)
      }
    }
  }


  func connected() {
#if canImport(UIKit)
    send(.appInfo(.current))
#endif
    sendActualTree()
    sendVCTree()
  }

  func failed(error: any Error) {
    print("Failed with: \(error)")
  }
}


fileprivate extension NSPointerArray {
  func node(at index: Int) -> FeatureNode? {
    guard let pointer = pointer(at: index) else { return nil }
    return Unmanaged<FeatureNode>.fromOpaque(pointer).takeUnretainedValue()
  }

  func add(_ object: FeatureNode) {
    addPointer(Unmanaged.passUnretained(object).toOpaque())
  }

  func all() -> [FeatureNode] {
    (0..<count).compactMap { node(at: $0) }
  }

  func dto() -> [FeatureDTO] {
    (0..<count).compactMap { node(at: $0)?.dto }
  }

  func first(where predicate: (FeatureNode) -> Bool) -> FeatureNode? {
    for index in 0..<self.count {
      if let obj = node(at: index), predicate(obj)  {
        return obj
      }
    }
    return nil
  }

  func by(nodeID: FeatureNode.ID) -> FeatureNode? {
    first(where: { $0.id == nodeID })
  }
}

