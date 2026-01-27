
import SwiftUI

struct CircleToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    var isInvalid: Bool
    
    var col: Color { isInvalid ? .destructive : .textPrimary }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                if configuration.isOn {
                    Image(systemName: isInvalid ? "xmark" : "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isInvalid ? .destructive : .brandSecondary)
                } else {
                    Circle()
                        .stroke(isEnabled ? col : col.opacity(0.5) ,  lineWidth: 2)
                        .frame(width: 16, height: 16)
                }
            }
            .frame(width: 25, height: 25)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    configuration.isOn.toggle()
                }
            }

            configuration.label
        }
    }
}

struct CircleCheck: View {
    @Binding var isOn: Bool
    var isInvalid: Bool
    
    var body: some View {
        Toggle(isOn: $isOn){
            EmptyView()
        }
        .toggleStyle(CircleToggleStyle(isInvalid: isInvalid))
    }
}

