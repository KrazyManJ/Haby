
import SwiftUI
import SFSymbolsPicker

struct AddEditHabitView: View {
    @Binding var isViewPresented: Bool
    @State var viewModel: AddEditHabitViewModel = AddEditHabitViewModel()
    
    @State private var isIconPickerPresented = false
    
    var amountType = ["Km", "Litres"]
    @State private var habitName: String = ""
    @State private var selectedHabitType: HabitType = .Deadline
    @State private var selectedFrequency: HabitFrequency = .Daily
    // convert date to int64
    @State private var selectedTime = Date()
    @State private var goalAmount: Float = 0.0
    @State private var selectedAmountType: String = "Km"
    @State private var healthData = true
    @State private var selectedIcon: String = "star.fill"
    @State private var habitActive = true
    
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
                    .pickerStyle(NavigationLinkPickerStyle())
                }
                .pickerStyle(.menu)
                
                HStack{
                    Text("Pick Icon")
                    Spacer()
                    Button {
                        isIconPickerPresented.toggle()
                    } label: {
                        Image(systemName: selectedIcon)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
            
                Toggle("Turn off habit", isOn: $habitActive)
                
                Button("Save"){
                    saveHabit()
                    isViewPresented.toggle()
                }
            }
        }
        // todo zmenit nadpis na edit kdyz habit id == null
        .navigationTitle("Add Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading){
                Button("Close") {
                    isViewPresented.toggle()
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
    
        private func saveHabit() {
            let newHabit = HabitDefinition(
                id: UUID(),
                name: habitName,
                icon: selectedIcon,
                type: selectedHabitType,
                frequency: selectedFrequency,
                isActive: habitActive
            )
            
            viewModel.addNewHabit(habit: newHabit)
        }
    
}
#Preview {
    AddEditHabitView(isViewPresented: .constant(true),
                     viewModel: AddEditHabitViewModel())
}
