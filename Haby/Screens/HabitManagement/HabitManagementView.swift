

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
                    Text("habit")
                    Text("habit")
                    Text("habit")
                }
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
            .sheet(isPresented: $isAddEditHabitViewPresented) {
                NavigationStack {
                    AddEditHabitView(
                        isViewPresented: $isAddEditHabitViewPresented,
                        viewModel: viewModel
                    )
                }
            }
        }
    }
}

#Preview {
    //HabitManagementView()
}
