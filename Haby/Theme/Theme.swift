

import Foundation
import SwiftUI

struct Theme {
  var button: Button

  struct Button {
    var primary: Primary

    struct Primary {
      var color: Color
    }
  }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 45)
            .padding(.horizontal)
            .background(Color.Primary)
            .foregroundColor(Color.TextLight)
            .cornerRadius(15)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}


extension Theme {
  static let `default` = Self(
    button: .init(
        primary: .init(color: .Primary)
    )
  )
}

private struct ThemeEnvironmentKey: EnvironmentKey {
  static var defaultValue = Theme.default
}

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeEnvironmentKey.self] }
    set { self[ThemeEnvironmentKey.self] = newValue }
  }
}
