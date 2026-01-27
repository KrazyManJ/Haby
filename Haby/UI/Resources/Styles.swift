import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 48)
            .bold()
            .padding(.horizontal)
            .background(isEnabled ? .brandPrimary : .textSecondary)
            .foregroundColor(.textOnPrimary)
            .cornerRadius(16)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
