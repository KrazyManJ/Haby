

import SwiftUI

struct HabitManagementView: View {
    @StateObject private var viewModel: HabitManagementViewModel
    @State var isAddEditHabitViewPresented = false
    @State var showAlert = false
    @State private var habitToDelete: HabitDefinition? = nil
    @State private var habitToEdit: HabitDefinition?
    @ObservedObject var sessionManager = PhoneSessionManager.shared
    @Environment(\.scenePhase) var scenePhase
    
    init(viewModel: HabitManagementViewModel = HabitManagementViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack{
            if !viewModel.state.habits.isEmpty {
                List {
                    ForEach(viewModel.state.habits) { habit in
                        HabitRow(
                            habit: habit
                        )
                        .listRowBackground(Colors.BackgroundSecondary)
                        .onTapGesture {
                            habitToEdit = habit
                        }
                        .swipeActions {
                            Button() {
                                habitToDelete = habit
                                showAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            else {
                Text("You have no defined habits, tap...").italic().foregroundColor(Color.gray).padding(.vertical,16)
                Image(systemName: "plus.circle").foregroundStyle(Color.gray).font(.system(size: 64))
                Text("...at the top right corner.").italic().foregroundColor(Color.gray).padding(.vertical,16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear{
            viewModel.fetchHabits()
        }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    print("App returned to foreground. Refreshing data...")
                    sessionManager.syncAllHabitsToWatch()
                }
            }
        .sheet(item: $habitToEdit, onDismiss: {
            viewModel.fetchHabits()
        }) { habit in
            NavigationStack {
                AddEditHabitView(
                    isViewPresented: .constant(true),
                    viewModel: AddEditHabitViewModel(habit: habit)
                )
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete this habit?"),
                message: Text("You will not be able to recover this habit's data after deletion."),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .destructive(Text("Delete")) {
                    if let habit = habitToDelete {
                        viewModel.removeHabit(habit: habit)
                    }
                }
            )
        }
        .background(Colors.BackgroundPrimary)
    }
}

#Preview {
    //HabitManagementView()
}




