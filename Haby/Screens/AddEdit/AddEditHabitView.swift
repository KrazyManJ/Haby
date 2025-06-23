
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
    //@State private var healthData = false
    @State private var selectedIcon: String = "star.fill"
    @State private var habitActive = true
    
    init(isViewPresented: Binding<Bool>, viewModel: AddEditHabitViewModel) {
        self._isViewPresented = isViewPresented
        self.viewModel = viewModel
        
        if let habit = viewModel.habitToEdit {
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
            _selectedAmountType = State(initialValue: habit.targetValueUnit ?? .None)
            //_healthData = State(initialValue: habit.isUsingHealthData)
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
                
                Picker("Habit type", selection: $selectedHabitType) {
                    ForEach(HabitType.allCases){ option in
                        Text(option.name)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(Color.Primary)
                
                
                if selectedHabitType == .Amount {
                    HStack {
                        if selectedAmountType == .Steps {
                            FloatTextField(value: $goalAmount, rawText: $amountText)
                        } else {
                            FloatTextField(value: $goalAmount, rawText: $amountText)
                        }
                        
                        Picker("Amount type", selection: $selectedAmountType) {
                            ForEach(AmountUnit.allCases){ option in
                                Text(option.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .accentColor(Color.Primary)
                    }
                    if (selectedAmountType == .Steps){
                        Toggle("Use Health Data", isOn: $viewModel.healthData)
                    }
                }
                Picker("Repetition", selection: $selectedFrequency) {
                    ForEach(HabitFrequency.allCases) { option in
                        Text(option.name)
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                    .accentColor(Color.Primary)
                }
                .pickerStyle(.menu)
                if selectedHabitType != .Amount {
                switch selectedFrequency {
                case .Daily:
                        DatePicker(
                            "Daily Time",
                            selection: $selectedTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                    
                case .Weekly:
                        DatePicker(
                            "Weekly Time",
                            selection: $selectedTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        Picker("Day of the Week", selection: $selectedDay){
                            ForEach(WeekDay.allCases) { option in
                                Text(option.name)
                            }
                            .pickerStyle(NavigationLinkPickerStyle())
                            .accentColor(Color.Primary)
                        }
                    }
                }
                
                HStack{
                    Text("Pick Icon")
                    Spacer()
                    Button{
                        isIconPickerPresented.toggle()
                    } label: {
                        HStack{
                            Image(systemName: selectedIcon)
                                .foregroundColor(.Primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundColor(Color.Primary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.habitToEdit == nil ? "Add Habit" : "Edit Habit")
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
            .buttonStyle(PrimaryButtonStyle())
            .padding(15)
            .disabled(habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !isGoalAmountInputValid())
        }
        .background(Color.Background)
    }
       
    
    private func saveHabit() {
        
        var timestamp = selectedTime.hourAndMinutesToMinutesTimestamp
        if selectedFrequency == .Weekly {
            timestamp += selectedDay.toTimestamp
        }
        
        let newHabit = HabitDefinition(
            id: viewModel.habitToEdit?.id ?? UUID(),
            name: habitName,
            icon: selectedIcon,
            type: selectedHabitType,
            frequency: selectedFrequency,
            targetTimestamp: timestamp,
            targetValue: goalAmount,
            targetValueUnit: selectedAmountType,
            isActive: habitActive,
            isUsingHealthData: viewModel.healthData
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
    AddEditHabitView(isViewPresented: .constant(true),
                     viewModel: AddEditHabitViewModel())
}
