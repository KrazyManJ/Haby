
import SwiftUI
import SFSymbolsPicker
import HealthKit

struct AddEditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isViewPresented: Bool
    @Bindable var viewModel: AddEditHabitViewModel
    
    @State private var isIconPickerPresented = false
    
    @State private var habitName: String = ""
    @State private var selectedHabitType: HabitType = .Deadline
    @State private var selectedFrequency: HabitFrequency = .Daily
    @State private var selectedDay: WeekDay = .Monday

    @State private var selectedTime = Date()
    @State private var goalAmount: Float = 0.0
    @State private var amountText: String = "0"

    @State private var selectedAmountType: AmountUnit = .None
    @State private var healthData = false
    @State private var selectedIcon: String = "star.fill"
    @State private var habitActive = true
    
    init(isViewPresented: Binding<Bool>, viewModel: AddEditHabitViewModel) {
        self._isViewPresented = isViewPresented
        self.viewModel = viewModel
        
        if let habit = viewModel.state.habitToEdit {
            _habitName = State(initialValue: habit.name)
            _selectedHabitType = State(initialValue: habit.type)
            _selectedFrequency = State(initialValue: habit.frequency)
            if let timestamp = habit.targetTimestamp {
                _selectedTime = State(initialValue: Date.fromMinutesTimestamp(timestamp: timestamp))
                if habit.frequency == .Weekly {
                    _selectedDay = State(initialValue: WeekDay(from: timestamp))
                }
            }
            _goalAmount = State(initialValue: habit.targetValue ?? 0)
            _amountText = State(initialValue: String(habit.targetValue ?? 0))
            _selectedAmountType = State(initialValue: habit.targetValueUnit ?? .None)
            _healthData = State(initialValue: habit.isUsingHealthData)
            _selectedIcon = State(initialValue: habit.icon)
            _habitActive = State(initialValue: habit.isActive)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField(
                    "Habit Name",
                    text: $habitName
                )
                .listRowBackground(Colors.BackgroundSecondary)
                .foregroundStyle(Colors.TextPrimary)
                
                Picker("Habit type", selection: $selectedHabitType) {
                    ForEach(HabitType.allCases){ option in
                        Text(option.name)
                    }
                }
                .listRowBackground(Colors.BackgroundSecondary)
                .foregroundStyle(Colors.TextPrimary)
                .pickerStyle(.menu)
                
                if selectedHabitType == .Amount {
                    HStack {
                        FloatTextField(value: $goalAmount, rawText: $amountText)
                            .foregroundStyle(Colors.TextPrimary)
                        Picker("Amount type", selection: $selectedAmountType) {
                            ForEach(AmountUnit.allCases){ option in
                                Text(option.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .foregroundStyle(Colors.TextPrimary)
                    }
                    .listRowBackground(Colors.BackgroundSecondary)
                    if (
                        selectedAmountType == .Steps ||
                        selectedAmountType == .Calories ||
                        selectedAmountType == .ExerciseTime ||
                        selectedAmountType == .Kilometers
                    ){
                        Toggle("Use Health Data", isOn: $healthData)
                            .onChange(of: healthData) { old, new in
                                if new {
                                    viewModel.requestHealthAuthorization()
                                }
                            }
                            .listRowBackground(Colors.BackgroundSecondary)
                    }
                }
                Picker("Repetition", selection: $selectedFrequency) {
                    ForEach(HabitFrequency.allCases) { option in
                        Text(option.name)
                    }
                }
                .pickerStyle(.menu)
                .listRowBackground(Colors.BackgroundSecondary)
                .foregroundStyle(Colors.TextPrimary)
                
                if selectedHabitType != .Amount {
                    
                switch selectedFrequency {
                    case .Daily:
                        DatePicker(
                            "Daily Time",
                            selection: $selectedTime,
                            displayedComponents: [.hourAndMinute],
                        )
                        .datePickerStyle(.wheel)
                        .colorMultiply(Colors.TextPrimary)
                        .listRowBackground(Colors.BackgroundSecondary)
                    
                    case .Weekly:
                        DatePicker(
                            "Weekly Time",
                            selection: $selectedTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .colorMultiply(Colors.TextPrimary)
                        .listRowBackground(Colors.BackgroundSecondary)
                        Picker("Day of the Week", selection: $selectedDay){
                            ForEach(WeekDay.allCases) { option in
                                Text(option.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .colorMultiply(Colors.TextPrimary)
                        .listRowBackground(Colors.BackgroundSecondary)
                    }
                }
                
                HStack{
                    Text("Pick Icon")
                        .foregroundStyle(Colors.TextPrimary)
                    Spacer()
                    Button{
                        isIconPickerPresented.toggle()
                    } label: {
                        HStack{
                            Image(systemName: selectedIcon)
                            Image(systemName: "chevron.up.chevron.down")
                        }
                    }
                }
                .listRowBackground(Colors.BackgroundSecondary)
            }
            .scrollContentBackground(.hidden)
            .background(Colors.BackgroundPrimary)
            .navigationTitle(viewModel.state.habitToEdit == nil ? "Add Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading){
                    Button("Close") {
                        isViewPresented.toggle()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isIconPickerPresented) {
                SymbolsPicker(
                    selection: $selectedIcon,
                    title: "Choose your symbol",
                    searchLabel: "Search symbols...",
                    autoDismiss: true
                ) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.accentColor)
                }
            }
            Button{
                saveHabit()
                dismiss()
            } label: {
                Text("Save Habit")
            }
            .padding(15)
            .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !isGoalAmountInputValid())
        }
        .background(Colors.BackgroundPrimary)
    }
       
    
    private func saveHabit() {
        
        var timestamp: Int? = selectedTime.hourAndMinutesToMinutesTimestamp
        if selectedFrequency == .Weekly {
            timestamp! += selectedDay.toTimestamp
        }
        if selectedHabitType == .Amount {
            timestamp = nil
        }
        
        let newHabit = HabitDefinition(
            id: viewModel.state.habitToEdit?.id ?? UUID(),
            name: habitName,
            icon: selectedIcon,
            creationDate: Date(),
            type: selectedHabitType,
            frequency: selectedFrequency,
            targetTimestamp: timestamp,
            targetValue: goalAmount,
            targetValueUnit: selectedAmountType,
            isActive: habitActive,
            isUsingHealthData: healthData
        )
        viewModel.addOrUpdateHabit(habit: newHabit)
    }
    
    func isGoalAmountInputValid() -> Bool {
        guard selectedHabitType == .Amount else { return true }
        guard let value = Float(amountText), value > 0 else { return false }
        if selectedAmountType == .Steps && amountText.contains(".") {
                return false
            }
        return true
    }

}
#Preview {
    AddEditHabitView(
        isViewPresented: .constant(true),
        viewModel: AddEditHabitViewModel()
    )
}
