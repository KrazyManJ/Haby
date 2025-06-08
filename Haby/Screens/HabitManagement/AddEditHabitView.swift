
import SwiftUI

struct AddEditHabitView: View {
    @Binding var isViewPresented: Bool
    @State var viewModel: HabitManagementViewModel
    
    var habitType = ["deadline", "ontime", "amount"]
    var repetitionType = ["daily", "weekly"]
    var amountType = ["Km", "l"]
    @State private var habitName: String = ""
    @State private var selectedType: String = "deadline"
    @State private var selectedRepetition: String = "daily"
    @State private var selectedTime = Date()
    @State private var goalAmount: String = "0"
    @State private var selectedAmountType: String = "Km"
    @State private var healthData = true
    @State private var notificationsOn = true
    @State private var icon: String = ""
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
            
            Picker("Habit type", selection: $selectedType) {
                ForEach(habitType, id: \.self) { test in
                    Text(test)
                }
            }
            .pickerStyle(.menu)
            
            if selectedType == "amount" {
                HStack {
                    TextField(
                        "Goal Amount",
                        value: $goalAmount,
                        formatter: formatter
                    )
                }
                Picker("Habit type", selection: $selectedAmountType) {
                    ForEach(amountType, id: \.self) { test in
                        Text(test)
                    }
                }
                .pickerStyle(.menu)
                Toggle("Use Health Data", isOn: $notificationsOn)

            } else {
                DatePicker(
                    "chce to string",
                    selection: $selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
            }
            
            switch selectedType {
            case "deadline":
                Text("deadline")
            case "ontime":
                Text("ontime")
            case "amount":
                Text("amount")
            default:
                Text("deadline")
            }
            
            
            Picker("Repetition", selection: $selectedRepetition) {
                ForEach(repetitionType, id: \.self) { test in
                    Text(test)
                }
            }
            .pickerStyle(.menu)
            Toggle("Turn on notifications", isOn: $notificationsOn)
            //icon picker
            Toggle("Turn off habit", isOn: $habitActive)
            
            Button("Save"){
//                saveHabit()
                isViewPresented.toggle()
            }
        }
        .navigationTitle("New Habit")
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
//    }
}

#Preview {
//    AddEditHabitView(isViewPresented: .constant(true),
//                     viewModel: HabitManagementViewModel())
}
