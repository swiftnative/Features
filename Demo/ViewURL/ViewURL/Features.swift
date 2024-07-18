//
//  ContentView.swift
//  ViewURL
//
//  Created by Alexey Nenastev on 5.7.24..
//

import SwiftUI
import Features

@Feature
struct FeaturesView {

  var featureBody: some View {
    NavigationView {
      List {
        NavigationLink("GotoFeature1") {
          Feature1()
        }
        
        NavigationLink("GotoFeature1") {
          Feature1()
        }

        NavigationLink("Goto-Feature2") {
          Feature2()
            .onOpenURL { incomingURL in
              print("Feature2 via URL: \(incomingURL)")
            }
        }

      }
    }
  }
}

#Preview {
  FeaturesView()
}
