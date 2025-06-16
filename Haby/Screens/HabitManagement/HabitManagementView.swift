

import SwiftUI

struct HabitManagementView: View {
    @State private var viewModel: HabitManagementViewModel
    @State var isAddEditHabitViewPresented = false
    
    init(viewModel: HabitManagementViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    ForEach(viewModel.state.habits) { habit in
                        Text(habit.name)
                    }
                }
            }
            .onAppear{
                viewModel.fetchHabits()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Habits Management")
            .toolbar{
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button(action: {
                        isAddEditHabitViewPresented.toggle()
                    }) {
                        Label("New Habit", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $isAddEditHabitViewPresented, onDismiss: {viewModel.fetchHabits()}) {
                NavigationStack {
                    AddEditHabitView(
                        isViewPresented: $isAddEditHabitViewPresented
                    )
                }
            }
        }
    }
}

#Preview {
    //HabitManagementView()
}
