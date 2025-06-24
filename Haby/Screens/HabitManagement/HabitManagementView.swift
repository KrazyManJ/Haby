

import SwiftUI

struct HabitManagementView: View {
    @StateObject private var viewModel: HabitManagementViewModel
    @State var isAddEditHabitViewPresented = false
    @State var showAlert = false
    @State private var habitToDelete: HabitDefinition? = nil
    @State private var habitToEdit: HabitDefinition?
    
    init(viewModel: HabitManagementViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                if !viewModel.state.habits.isEmpty {
                    List {
                        ForEach(viewModel.state.habits) { habit in
                            HabitRow(
                                habit: habit
                            )
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
                    .listRowBackground(Color.clear)
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Habits Management")
            .toolbar{
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button(action: {
                        isAddEditHabitViewPresented = true
                    }) {
                        Label("New Habit", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .tint(Color.Primary)
            .sheet(item: $habitToEdit, onDismiss: {
                viewModel.fetchHabits()
            }
            ) { habit in
                NavigationStack {
                    AddEditHabitView(
                        isViewPresented: .constant(true),
                        viewModel: AddEditHabitViewModel(habit: habit)
                    )
                }
            }
            .sheet(isPresented: $isAddEditHabitViewPresented, onDismiss: {
                viewModel.fetchHabits()
            }) {
                NavigationStack {
                    AddEditHabitView(
                        isViewPresented: .constant(true),
                        viewModel: AddEditHabitViewModel()
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
            .background(Color.Background)
        }
    }
}

#Preview {
    //HabitManagementView()
}




