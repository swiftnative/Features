//
// Created by Alexey Nenastyev on 4.7.24.
// Copyright © 2024 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Shared
import Features
import Observation
import Combine

extension ExpiredButton: FeatureBody {

  public var featureBody: some View {
    ExpiredButtonView(feature: self)
  }
}

struct ExpiredButtonView: View {
  let feature: ExpiredButton
  @State var model = ExpiredButtonModel()

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
      model.startTimer(duration: .seconds(10))
    }
  }
}

@Observable
final class ExpiredButtonModel {

  var timeRemaining: Int = 0
  var expired: Bool {
    timeRemaining == 0
  }

  @ObservationIgnored
  private var timer: AnyCancellable?

  func startTimer(duration: Duration) {
    timer?.cancel()
    timeRemaining = Int(duration.components.seconds)
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
  Shared.ExpiredButton(title: "It's button!",
               logo: "birthday.cake",
               action: {})
}
