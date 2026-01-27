
import SwiftUI
import SFSymbolsPicker
import HealthKit

fileprivate extension View {
    func formFieldCustomStyles() -> some View {
        self
            .listRowBackground(Colors.BackgroundSecondary)
            .listRowSeparator(.hidden)
            .foregroundStyle(Colors.TextPrimary)
    }
}

struct AddEditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var isIconPickerPresented = false
    
    @StateObject var viewModel: AddEditHabitViewModel
        
    var habitDescriptionSection: some View {
        Section {
            HStack {
                Button(action: {
                    isIconPickerPresented = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.state.habit.icon)
                            .foregroundStyle(.accent)
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(.textSecondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderless)
                TextField(
                    "",
                    text: $viewModel.state.habit.name,
                    prompt: Text("Enter a habit name...").foregroundStyle(.textSecondary.opacity(0.5))
                )
            }
                .formFieldCustomStyles()
        } header: {
            Text("Habit description")
                .foregroundStyle(.textSecondary)
                .textCase(nil)
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder var habitSpecificSettings: some View {
        if viewModel.state.selectedHabitType == .Amount {
            HStack {
                TextField("Enter decimal", value: $viewModel.state.amountInput, format: .number)
                    .keyboardType(.decimalPad)
                Picker("Amount type", selection: $viewModel.state.selectedAmountType) {
                    ForEach(AmountUnit.allCases){ option in
                        Text(option.name)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .foregroundStyle(Colors.TextPrimary)
            }
            .listRowBackground(Colors.BackgroundSecondary)
            if viewModel.state.selectedAmountType.isHealthData {
                Toggle("Use Health Data", isOn: $viewModel.state.healthData)
                    .onChange(of: viewModel.state.healthData) { old, new in
                        if new {
                            viewModel.requestHealthAuthorization()
                        }
                    }
                    .listRowBackground(Colors.BackgroundSecondary)
            }
        }
        
        if viewModel.state.selectedHabitType != .Amount {
            
            switch viewModel.state.selectedFrequency {
            case .Daily:
                DatePicker(
                    "Daily Time",
                    selection: $viewModel.state.selectedTime,
                    displayedComponents: [.hourAndMinute],
                )
                .datePickerStyle(.wheel)
                .colorMultiply(Colors.TextPrimary)
                .listRowBackground(Colors.BackgroundSecondary)
            
            case .Weekly:
                DatePicker(
                    "Weekly Time",
                    selection: $viewModel.state.selectedTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .colorMultiply(Colors.TextPrimary)
                .listRowBackground(Colors.BackgroundSecondary)
                Picker("Day of the Week", selection: $viewModel.state.selectedDay){
                    ForEach(WeekDay.allCases) { option in
                        Text(option.name)
                    }
                }
                .pickerStyle(.menu)
                .colorMultiply(Colors.TextPrimary)
                .listRowBackground(Colors.BackgroundSecondary)
            }
        }
    }
    
    var habitSettings: some View {
        Section {
            Picker("Repetition", selection: $viewModel.state.selectedFrequency) {
                ForEach(HabitFrequency.allCases) { option in
                    Text(option.name)
                }
            }
                .pickerStyle(.menu)
                .formFieldCustomStyles()
            VStack(alignment: .leading) {
                Picker("Habit type", selection: $viewModel.state.selectedHabitType) {
                    ForEach(HabitType.allCases){ option in
                        Text(option.name)
                    }
                }
                    .pickerStyle(.menu)
                Text(viewModel.state.selectedHabitType.description)
                    .foregroundStyle(.textSecondary)
                    .font(.caption)
            }
                .formFieldCustomStyles()
            
            habitSpecificSettings
        } header: {
            Text("Habit settings")
                .foregroundStyle(.textSecondary)
                .textCase(nil)
        }
        .scrollContentBackground(.hidden)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                habitDescriptionSection
                habitSettings
                
                
            }
            .scrollContentBackground(.hidden)
            .background(Colors.BackgroundPrimary)
            .navigationTitle(viewModel.state.isEdit ? "Edit Habit" : "Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading){
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            Button{
                viewModel.addOrUpdateHabit()
                dismiss()
            } label: {
                Text("Save Habit")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(16)
            .disabled(!viewModel.state.isValid)
        }
        .background(Colors.BackgroundPrimary)
        .navigationDestination(isPresented: $isIconPickerPresented) {
            SymbolsPicker(
                selection: $viewModel.state.habit.icon,
                title: "Pick icon",
                searchLabel: "Search symbols...",
                autoDismiss: true
            ) {
                Image(systemName: "xmark.circle")
            }
            .background(.backgroundPrimary)
        }
    }
}
#Preview {
    @Previewable @State var presented = true
    
    NavigationStack {}
        .sheet(isPresented: $presented) {
            AddEditHabitView(
                viewModel: AddEditHabitViewModel()
            )
        }
        .preferredColorScheme(.dark)
        .background(.backgroundPrimary)
}
