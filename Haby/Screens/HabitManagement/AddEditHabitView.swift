
import SwiftUI
import SFSymbolsPicker

struct AddEditHabitView: View {
    @Binding var isViewPresented: Bool
    @State var viewModel: HabitManagementViewModel
    
    @State private var icon = "star.fill"
    @State private var isIconPickerPresented = false
    
    var habitType = ["deadline", "ontime", "amount"]
    var repetitionType = ["daily", "weekly"]
    var amountType = ["Km", "Litres"]
    @State private var habitName: String = ""
    @State private var selectedHabitType: HabitType = .Deadline
    @State private var selectedFrequency: HabitFrequency = .Daily
    // convert date to int64
    @State private var selectedTime = Date()
    @State private var goalAmount: Float = 0.0
    @State private var selectedAmountType: String = "Km"
    @State private var healthData = true
    @State private var notificationsOn = true
    @State private var selectedIcon: String = ""
    @State private var habitActive = true
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
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
                        ForEach(amountType, id: \.self) { test in
                            Text(test)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                Toggle("Use Health Data", isOn: $healthData)
                
            } else {
                DatePicker(
                    "chce to string",
                    selection: $selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
            }
            
            Picker("Repetition", selection: $selectedFrequency) {
                ForEach(HabitFrequency.allCases) { option in
                    Text(option.name)
                }
                .pickerStyle(NavigationLinkPickerStyle())            }
            .pickerStyle(.menu)
            Toggle("Turn on notifications", isOn: $notificationsOn)
            //icon picker
            Picker("Icon", selection: $selectedIcon) {
                ForEach(HabitFrequency.allCases) { option in
                    Text(option.name)
                }
            }
            .pickerStyle(.menu)
            
            
            Toggle("Turn off habit", isOn: $habitActive)
            
            Button("Save"){
                //                saveHabit()
                isViewPresented.toggle()
            }
        }
        // todo zmenit nadpis na edit kdyz habit id == null
        .navigationTitle("Add Habit")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading){
                Button("Close") {
                    isViewPresented.toggle()
                }
            }
        }
    }
    
    //    private func saveHabit() {
    //        let newHabit = Habit(
    //            id: UUID(),
    //            name: habitName,
    //            type: habitType,
    //            repetition: repetition,
    //            notificationsOn: notificationsOn,
    //            icon: icon,
    //            habitActive: habitActive
    //        )
    //        
    //        viewModel.addNewHabit(habit: newHabit)
    //        viewModel.fetchHabits()
    //    }
}

#Preview {
//    AddEditHabitView(isViewPresented: .constant(true),
//                     viewModel: HabitManagementViewModel())
}
