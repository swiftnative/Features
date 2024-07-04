//
//  FeatureAView.swift
//  FeatureA
//
//  Created by Alexey Nenastev on 3.7.24..
//

import SwiftUI
import Features
import Shared

extension DependenciesGraph: FeatureBody {
  public var featureBody: some View {
    DependenciesGraphView(selected: selected)
  }
}


enum Graph {
  static var nodes: TreeNode {
    var root = TreeNode(name: "App", color: .mint, children: [
      TreeNode(name: "Module A", color: .blue, children: [
        TreeNode(name: "Module B", color: .blue),
      ]),
      TreeNode(name: "Module C", color: .blue),
    ])

    root.populateParentNodeIds()

    return root
  }
}

struct DependenciesGraphView: View {
  @State var nodeSeparation: CGFloat = 80.0
  @State var rowSeparation: CGFloat = 30.0
  @State var path: Path = Path()

  let selected: String

  func nodeView(name: String, color: Color) -> some View {
    Text(name)
      .frame(minWidth: 0, maxWidth: .infinity)
      .padding(20)
      .background {
        RoundedRectangle(cornerRadius: 15)
          .fill(color.gradient)
          .shadow(radius: 3.0)
      }
  }

  var body: some View {
    let dash = StrokeStyle(lineWidth: 2, dash: [3, 3], dashPhase: 0)

    VStack(spacing: 0) {
      TreeLayout(nodeSeparation: nodeSeparation, rowSeparation: rowSeparation, linesPath: $path) {
        ForEach(Graph.nodes.flattenNodes) { node in
          let color = node.name == selected ? Color.yellow : node.color
          nodeView(name: node.name, color: color)
            .node(node.id, parentId: node.parentId)
        }
      }
      .background {
        path.stroke(.gray, style: dash)
      }
      .padding(30)
      .bold()
      .foregroundColor(.white)

      nodeView(name: "Shared", color: .cyan)
        .padding(.horizontal, 40)
    }
    .padding(.bottom, 20)
    .border(Color.gray)
    Text("We have two shared features declared in **Shared**: DependenciesGraph, ExpiredButton and use them in all modules A, B, C")
  }

}

#Preview {
  DependenciesGraph(selected: "Module A")
  Spacer()
}
