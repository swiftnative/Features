//
//  ScreenPicker.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 9.9.24..
//
import SwiftUI

struct ScreenPicker: View {
  @Binding var animal: Animal?
  @State var isPresented: Bool = false

  var body: some View {
    Button(action: {
      isPresented.toggle()
    }) {
      if let animal {
        HStack {
          Image(systemName: animal.systemImage)
            .foregroundStyle(Color.accentColor)
          VStack(alignment: .leading) {
            Text(animal.name)
            Text(animal.description)
              .font(.footnote)
          }
          Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .border(Color.accentColor.opacity(0.5), width: 2)
      } else {
        Text("No animal selected.")
      }
    }
    .buttonStyle(.plain)
    .sheet(isPresented: $isPresented) {
      AnimalStack(animal: $animal)
        .modifier(.detents(.medium))
    }
  }
}

fileprivate struct AnimalStack: View {
  @Binding var animal: Animal?
  @Environment(\.dismiss) var dismiss

  var body: some View {
    List(Animal.allCases, selection: $animal) { animal in
      HStack {
        Image(systemName: animal.systemImage)
          .foregroundStyle(Color.accentColor)
        VStack(alignment: .leading) {
          Text(animal.name)
          Text(animal.description)
            .font(.footnote)
        }
      }
    }.onChange(of: animal, perform: { _ in
      dismiss()
    })
  }
}
