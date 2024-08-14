//
// Created by Alexey Nenastyev on 5.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Features

@Screen
struct StarView: View {
  @State var someBool = false

  var screenBody: some View {
    Group {
      if someBool {
        ProxyView()
      } else {
        Button(action: {
          someBool.toggle()
        }) {
          Text("Show Content")
        }
      }
    }
  }
}

struct ProxyView: View {
  @State var isSheetPresented  = false
  @State var current: String = ""

  let urls: [String] = [
    /// Должен сменить текущий таб
    "feature://app/home[tab=1]",
    "feature://app/home[tab=0]/features/feature[id=1]",
    "feature://app/home[tab=0]/feature-with-id[id=1]",
  ]

  var body: some View {
    NavigationStack {
      
      VStack(alignment: .leading, spacing: 10) {
        
        ForEach(urls, id: \.self) { url in
          Button {
            current = url
          } label: {
            Text(url)
          }
          .foregroundColor(current == url ? .blue : .black)
        }
        Divider()

        if let url = URL(string: current) {
          if let components = URLComponents(string: url.absoluteString) {
            LabeledContent("Scheme", value: "\(components.scheme ?? "")")
            LabeledContent("Host", value: "\(components.host ?? "")")
            LabeledContent("Fragment", value: "\(components.fragment ?? "")")
            Divider()
            Section("**Path**") {
              ForEach(url.pathComponents.indices, id: \.self) {
                LabeledContent("\($0)", value: url.pathComponents[$0])
              }
            }

            Section("**Query**") {
              if let items = components.queryItems {
                ForEach(items.indices, id: \.self) {
                  LabeledContent("\($0)", value: items[$0].description)
                }
              }
            }

          }
        }
        Spacer()
      }
      .onAppear(perform: {
        current = urls.first!
      })
      .navigationTitle(Text("is URL Valid?"))
      .multilineTextAlignment(.leading)
      .padding()
    }
  }
}

#Preview {
  StarView()
}