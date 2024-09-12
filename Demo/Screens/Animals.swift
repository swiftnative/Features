//
//  Dog 2.swift
//  DemoScreens
//
//  Created by Alexey Nenastev on 9.9.24..
//


import SwiftUI
import ScreensUI

public enum Animal: String, Identifiable, CaseIterable {
  case dog
  case cat

  public var id: Self { self }

  var systemImage: String {
    switch self {
    case .dog: return "dog"
    case .cat: return "cat"
    }
  }

  public var name: String {
    switch self {
    case .dog: return "Dog"
    case .cat: return "Cat"
    }
  }

  var description: String {
    switch self {
    case .dog: return "A cute dog"
    case .cat: return "A cute cat"
    }
  }

  var screen: any Screen {
    switch self {
    case .dog: Dog()
    case .cat: Cat()
    }
  }
}


@Screen
struct Dog {
  var screenBody: some View {
    AnimalScreenBody(animal: .dog)
  }
}

@Screen
struct Cat {
  var onScreenAppear: (ScreenAppearance) -> Void = { _ in }

  var screenBody: some View {
    AnimalScreenBody(animal: .cat)
      .onScreenAppear(onScreenAppear)
  }
}

@Screen
struct Cats {
  var onScreenAppear: (ScreenAppearance) -> Void = { _ in }

  var screenBody: some View {
    ScreenStack {
      AnimalScreenBody(animal: .cat)
        .onScreenAppear(onScreenAppear)
    }
  }
}

@Screen
struct Dogs {
  var onScreenAppear: (ScreenAppearance) -> Void = { _ in }

  var screenBody: some View {
    ScreenStack {
      AnimalScreenBody(animal: .dog)
        .onScreenAppear(onScreenAppear)
    }
  }
}


#Preview("Dog") {
  Dog()
}

#Preview("Cat") {
  Cat()
}
