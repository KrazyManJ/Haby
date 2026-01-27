import SwiftUI

struct CheckHabitButton: View {
    let isChecked: Bool
    let isValid: Bool
    let onToggle: () -> Void
    
    private let holdDuration: TimeInterval = 3.0
    @State private var isHolding = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.backgroundSecondary)
                
                Rectangle()
                    .fill(.brandSecondary.opacity(0.5))
                    .frame(width: isHolding ? geometry.size.width : 0)
                
                HStack {
                    Spacer()
                    if isChecked {
                        Text("Completed")
                            .foregroundStyle(isValid ? .brandPrimary : .destructive)
                            .font(.headline)
                    } else {
                        Text("Check Habit")
                            .foregroundStyle(.textPrimary)
                            .font(.headline)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            if isChecked {
                Button(action: onToggle) {
                    Color.clear
                }
            } else {
                Color.clear
                    .contentShape(Rectangle())
                    .onLongPressGesture(minimumDuration: holdDuration) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    onToggle()
                    
                    withAnimation(.easeOut(duration: 0.1)) {
                        isHolding = false
                    }
                } onPressingChanged: { isPressing in
                    if isPressing {
                        withAnimation(.easeInOut(duration: holdDuration)) {
                            isHolding = true
                        }
                    } else {
                        withAnimation(.easeOut(duration: 0.1)) {
                            isHolding = false
                        }
                    }
                }
            }
        }
    }
}
