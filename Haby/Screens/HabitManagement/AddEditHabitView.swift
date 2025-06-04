
import SwiftUI

struct AddEditHabitView: View {
    @Binding var isViewPresented: Bool
    @State var viewModel: HabitManagementViewModel
    
    var testType = ["apple", "banana", "orange"]
    @State private var habitName: String = ""
    @State private var habitType: String = "banana"
    @State private var repetition: String = ""
    @State private var notificationsOn = true
    @State private var icon: String = ""
    @State private var habitActive = true
    
    var body: some View {
        Form {
            
            TextField(
                "Habit Name",
                text: $habitName
            )
            
            Picker("Habit type", selection: $habitType) {
                ForEach(testType, id: \.self) { test in
                    Text(test)
                }
            }
            
            .pickerStyle(.menu)
            Toggle("Turn on notifications", isOn: $notificationsOn)
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
    AddEditHabitView(isViewPresented: .constant(true),
                     viewModel: HabitManagementViewModel())
}
