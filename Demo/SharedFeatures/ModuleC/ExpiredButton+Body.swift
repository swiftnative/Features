//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared
import Features
import Observation
import Combine

extension ExpiredButton: SharedscreenBody {

  public var sharedscreenBody: some View {
    ExpiredButtonView(feature: self)
  }
}

struct ExpiredButtonView: View {
  let feature: ExpiredButton
  @StateObject var model: ExpiredButtonModel

  init(feature: ExpiredButton) {
    self.feature = feature
    print("ExpiredButtonView init")
    // We use this initializer with @autoclusure to pass paramaeters to our Model
    _model = StateObject(wrappedValue:  ExpiredButtonModel(feature: feature))
  }

  var body: some View {
    Button(action: feature.action) {
      HStack {
        Image(systemName: feature.logo)
        Text(feature.title)
        if !model.expired {
          Text("\(model.timeRemaining, format: .number)")
            .frame(width: 20)
        }
      }
      .foregroundColor(.black)
      .padding()
      .background(Color.gray.opacity(0.4))
      .cornerRadius(8)
    }
    .disabled(model.expired)
    .opacity(model.expired ? 0.5 : 1)
    .animation(.default, value: model.expired)
    .onAppear {
      model.startTimer(duration: 10)
    }
  }
}

final class ExpiredButtonModel: ObservableObject {

  @Published var timeRemaining: Int = 0
  var expired: Bool {
    timeRemaining == 0
  }

  private var timer: AnyCancellable?

  let feature: ExpiredButton
  init(feature: ExpiredButton) {
    self.feature = feature
    print("ExpiredButtonModel inited")
  }

  func startTimer(duration: Int) {

    timer?.cancel()
    timeRemaining = duration
    timer = Timer.publish(every: 1.0, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
                      guard let self = self else { return }
                      if self.timeRemaining > 0 {
                          self.timeRemaining -= 1
                      } else {
                          self.timer?.cancel()
                      }
                  }
  }

}

#Preview {
  ExpiredButton(title: "It's button!")
}
