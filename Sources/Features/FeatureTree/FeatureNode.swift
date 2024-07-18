//
// Created by Alexey Nenastyev on 11.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import os
import FeaturesDomain

struct ParentFeatureIDKey : EnvironmentKey {
  static var defaultValue: UUID = .zero
}

extension EnvironmentValues {
  var parentNodeID: UUID {
    get { self[ParentFeatureIDKey.self] }
    set { self[ParentFeatureIDKey.self] = newValue }
  }
}

struct ChildsFeatueKey: PreferenceKey {
  static var defaultValue: [UUID] = []
  static func reduce(value: inout [UUID], nextValue: () -> [UUID]) {
    value += nextValue()
  }
}

final class FeatureNode: UIViewController, ObservableObject {
  typealias ID = UUID
  typealias Dismiss = () -> Void
  let id: ID = ID()
  let type: String!
  let file: StaticString!
  let featureID: String!

  var isLeaf: Bool { childrenNodes.isEmpty }
  var vcHierarhyInfo: [String] = []
//  var parents
  var parentNodeID: ID?
  var state: FeatureState
  private var isFirstAppear: Bool = true
  var dismiss: DismissAction?
  var info: String = ""
  var stack: NodeStackInfo?

  func fillStackInfo() {
    guard let navigationController else { return  }
    let index = navigationController.viewControllers.firstIndex(of: self) ?? -1
    self.stack = NodeStackInfo(stackID: "\(navigationController)", index: index)
  }

  func fillInfo() {

    self.info = ""

    func addInfo(_ title: String, _ vc: UIViewController?) {
      guard let vc else { return }
      self.info += "**\(title)**\n\(vc.description)\n\n"
    }

    addInfo("Presenting", presentingViewController)
    addInfo("Presented", presentedViewController)
    addInfo("Parent", parent)
    addInfo("Navigation Parent", navigationController?.parent)
  }

  func update() {
    fillStackInfo()
    fillHierarhyInfo()
    fillInfo()
  }

  static let root = FeatureNode(type: "App", featureID: "App", file: #file)
  let logger = Logger(subsystem: "com.example.MyViewController", category: "MyViewController")

  private var tree: FeatureTree { FeatureTree.shared }

  init(type: String, featureID: String, file: StaticString) {
    self.type = type
    self.featureID = featureID
    self.file = file
    self.state = .init()
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private(set) var childrenNodes: [FeatureNode.ID] = []

  fileprivate func onAppear(parentNodeID: UUID, isPresented: Bool, dismiss: DismissAction?) {
    self.parentNodeID = parentNodeID == .zero ? nil : parentNodeID
    self.dismiss = dismiss
    self.state.isAppeared = true
    self.state.isPresented = isPresented
    if isFirstAppear {
      isFirstAppear = false
      self.state.onApperPresented = isPresented
      tree.nodeCreated(node: self)
    } else {
      tree.nodeStateUpdated(node: self)
    }
  }

  private func fillHierarhyInfo() {
    var parents: [String] = []
    func scanParents(_ node: UIViewController?, infos: inout [String]) {
      guard let node else { return }
      infos.append(node.vcID)
      scanParents(node.parent, infos: &infos)
    }
    scanParents(self, infos: &parents)
    self.vcHierarhyInfo = parents.reversed()
  }

  fileprivate func onDissappear() {
    self.state.isAppeared = false
    tree.nodeStateUpdated(node: self)
  }

  fileprivate func onIsPresentedChanged(isPresented: Bool, dismiss: DismissAction?) {
    logger.debug("[\(self.featureID)] onIsPresentedChanged \(isPresented)")
    self.state.isPresented = isPresented
    self.dismiss = dismiss
    tree.nodeStateUpdated(node: self)
  }

  fileprivate func set(childs: [UUID]) {
    self.childrenNodes = childs
    //    browser.nodeChildsUpdated(node: self)
  }

  deinit {
    //    print("removed |" + String(reflecting: featureID!))
    logger.debug("[\(self.featureID)] deinit")
    tree.nodeRemoved(node: self.id)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    update()
    tree.nodeStateUpdated(node: self)
    //    logger.debug("[\(self.featureID)] viewDidAppear \(self.navigationController)")
  }



  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    logger.debug("[\(self.featureID)] didMove \(self.parent) \(self.navigationController)")
    update()
    tree.nodeStateUpdated(node: self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    logger.debug("[\(self.featureID)] viewDidLoad")
  }


}

extension UIViewController {
  var nodeDescription: String {
    var info: String = "**\(address)**\n"
    if let currentNode = self as? FeatureNode {
      info += currentNode.nodeDebugName
    } else {
      info += vcType
    }
    return info
  }

  var address: String {
    "\(Unmanaged.passUnretained(self).toOpaque())"
  }

  var vcType: String {
    Swift.type(of: self).description()
  }

  var vcID: String {
    address
  }

  @MainActor
  var vc: ViewController {
    let featureNode = self as? FeatureNode
    return ViewController(id: vcID,
                          type: vcType,
                          featureID: featureNode?.featureID,
                          featureNodeID: featureNode?.id,
                          address: address,
                          parentID: parent?.vcID)
  }

  var uuid: UUID {
    if let value = objc_getAssociatedObject(self, &uuidKey) as? UUID {
      return value
    } else {
      let newValue = UUID()
      objc_setAssociatedObject(self, &uuidKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return newValue
    }
  }
}

private var uuidKey: UInt8 = 0

struct FeatureNodeModifier: ViewModifier {

  @StateObject private var node: FeatureNode
  @Environment(\.isPresented) var isPresented
  @Environment(\.dismiss) var dismiss
  @Environment(\.parentNodeID) var parentNodeID

  init(type: String, featureID: String, file: StaticString) {
    _node = StateObject(wrappedValue: FeatureNode(type: type, featureID: featureID, file: file))
  }

  func body(content: Content) -> some View {
    content
      .preference(key: ChildsFeatueKey.self, value: [node.id])
      .onPreferenceChange(ChildsFeatueKey.self) { [weak node] childs in
        node?.set(childs: childs)
      }
      .environment(\.parentNodeID, node.id)
      .onAppear { [weak node] in
        node?.onAppear(parentNodeID: parentNodeID,
                       isPresented: isPresented,
                       dismiss: dismiss)
      }
      .onDisappear { [weak node] in
        node?.onDissappear()
      }
      .onChange(of: isPresented) { [weak node] in
        node?.onIsPresentedChanged(isPresented: $0, dismiss: dismiss)
      }
      .background {
        ViewControllerAccessor(node: node)
      }
  }
}

struct ViewControllerAccessor: UIViewControllerRepresentable {
  let node: FeatureNode

  func makeUIViewController(context: Context) -> FeatureNode {
    node
  }

  func updateUIViewController(_ uiViewController: FeatureNode, context: Context) {}
}

extension FeatureNode {

  var nodeDebugName: String {
    "[\(featureID!)-\(id.uuidString.prefix(5))]"
  }

  var nodeDebugDescription: String {
    "\(nodeDebugName) \(state) parent:\(parentNodeID?.uuidString.prefix(5) ?? "")"
  }

  var dto: FeatureDTO {
    FeatureDTO(id: id,
               featureID: featureID,
               type: type,
               parentNodeID: parentNodeID,
               state:  state,
               file: "\(file)",
               stack: stack,
               vcHierarhyInfo: vcHierarhyInfo,
               info: info)
  }
}
