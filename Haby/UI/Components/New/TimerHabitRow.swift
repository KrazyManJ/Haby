import SwiftUI

struct TimerHabitRow : View {
    
    let habit: HabitDefinition
    let isChecked: Bool
    let isValid: Bool
    let onCheck: () -> Void
    
    private let holdDuration: TimeInterval = 3.0
    
    @State private var isHolding = false
    
    var dateOfCompletion: Date {
        var minutes = 0
        switch habit.data {
        case .Deadline(let data): minutes = data.minutesOfCompletionInFrequency
        case .OnTime(let data): minutes = data.minutesOfCompletionInFrequency
        default:
            break
        }
        return Calendar.current.date(byAdding: .minute, value: minutes, to: Date().onlyDate)!
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Timeline()
            habitDetails
        }
    }
    
    var habitDetails: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(Colors.BackgroundSecondary)
                Rectangle()
                    .fill(Colors.Primary.opacity(0.5))
                    .frame(width: isHolding ? geometry.size.width : 0)
                HStack {
                    Image(systemName: habit.icon)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(habit.name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.callout)
                            .bold()
                    }
                    Spacer()
                    Text(dateOfCompletion, format: .relative(presentation: .named))
                        .foregroundStyle(.textSecondary)
                        .font(.footnote)
                    CheckBox(isOn: .constant(isChecked), isInvalid: !isValid)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .if(isChecked && !isValid) {
            $0.foregroundStyle(.destructive)
        }
        .if(isChecked) {
            $0.foregroundStyle(.brandPrimary)
        }
        .foregroundStyle(.textPrimary)
        .frame(height: 48)
        .if(isChecked) {
            $0.onTapGesture {
                onCheck()
            }
        }
        .if(!isChecked) {
            $0.onLongPressGesture(minimumDuration: holdDuration) {
                onCheck()
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
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

#Preview {
    @Previewable @State var isCheckedFirst = false
    @Previewable @State var isCheckedSecond = false
    
    let habit = HabitDefinition(
        name: "Take shower with someone you really love",
        icon: "shower",
        type: .Deadline,
        frequency: .Daily,
        data: .Deadline(data: .init(frequency: .Daily, minutesOfCompletionInFrequency: 60*12))
    )
    VStack(spacing: 0) {
        TimerHabitRow(habit: habit, isChecked: isCheckedFirst, isValid: true) {
            isCheckedFirst = true
        }
        TimerHabitRow(habit: habit, isChecked: isCheckedSecond, isValid: false) {
            isCheckedSecond = true
        }
    }
    .preferredColorScheme(.dark)
}
