
import SwiftUI
import SFSymbolsPicker

struct AddEditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isViewPresented: Bool
    @ObservedObject var viewModel: AddEditHabitViewModel
    
    @State private var isIconPickerPresented = false
    
    var amountTypes = ["Km", "Litres", "Steps"]
    @State private var amountType: String = "Km"
    @State private var habitName: String = ""
    @State private var selectedHabitType: HabitType = .Deadline
    @State private var selectedFrequency: HabitFrequency = .Daily
    @State private var selectedDay: WeekDay = .Monday
    // convert date to int64
    @State private var selectedTime = Date()
    @State private var goalAmount: Float = 0.0
    @State private var selectedAmountType: String = "Km"
    @State private var healthData = true
    @State private var selectedIcon: String = "star.fill"
    @State private var habitActive = true
    
    init(isViewPresented: Binding<Bool>, viewModel: AddEditHabitViewModel) {
        self._isViewPresented = isViewPresented
        self.viewModel = viewModel
        
        if let habit = viewModel.habitToEdit {
            _habitName = State(initialValue: habit.name)
            _selectedHabitType = State(initialValue: habit.type)
            _selectedFrequency = State(initialValue: habit.frequency)
            _goalAmount = State(initialValue: habit.targetValue ?? 0)
            _selectedAmountType = State(initialValue: habit.targetValueUnit ?? "")
            _healthData = State(initialValue: habit.isUsingHealthData)
            _selectedIcon = State(initialValue: habit.icon)
            _habitActive = State(initialValue: habit.isActive)
        }
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
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
                        // todo check km/litr int/float
                        TextField(
                            "Goal Amount",
                            value: $goalAmount,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        Picker("Amount type", selection: $selectedAmountType) {
                            ForEach(amountTypes, id: \.self) { test in
                                Text(test)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    }
                    Toggle("Use Health Data", isOn: $healthData)
                    
                } else {
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
                        }
                    }
                }
                
                Picker("Repetition", selection: $selectedFrequency) {
                    ForEach(HabitFrequency.allCases) { option in
                        Text(option.name)
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                }
                .pickerStyle(.menu)
                
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
                        }
                    }
                }
                
                Toggle("Turn off habit", isOn: $habitActive)
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
        }
        Button{
            saveHabit()
            dismiss()
        } label: {
            Text("Save Habit")
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(15)
    }
    private func saveHabit() {
            let newHabit = HabitDefinition(
                id: viewModel.habitToEdit?.id ?? UUID(),
                name: habitName,
                icon: selectedIcon,
                type: selectedHabitType,
                frequency: selectedFrequency,
                targetValue: goalAmount,
                targetValueUnit: selectedAmountType,
                isActive: habitActive,
                isUsingHealthData: healthData
            )
        viewModel.addOrUpdateHabit(habit: newHabit)
    }
    
}
#Preview {
    AddEditHabitView(isViewPresented: .constant(true),
                     viewModel: AddEditHabitViewModel())
}
