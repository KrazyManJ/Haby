

import SwiftUI

struct HabitManagementView: View {
    @StateObject private var viewModel: HabitManagementViewModel
    @State var isAddEditHabitViewPresented = false
    @State var showAlert = false
    @State private var habitToDelete: HabitDefinition? = nil
    @State private var habitToOpen: HabitDefinition?
    @State private var showDetail: Bool = false
    @Environment(\.scenePhase) var scenePhase
    
    init(viewModel: HabitManagementViewModel = HabitManagementViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack{
            if !viewModel.state.habits.isEmpty {
                NavigationStack {
                    List {
                    ForEach(viewModel.groupedHabits, id: \.category) { group in
                            Section(header:
                                Text(group.category)
                                    .font(.headline)
                                    .foregroundStyle(Colors.TextPrimary)
                                    .textCase(nil)
                            ) {
                                ForEach(group.habits) { habit in
                                    HabitRow(habit: habit)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Colors.BackgroundSecondary)
                                        .onTapGesture {
                                            habitToOpen = habit
                                            showDetail = true
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
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationDestination(isPresented: $showDetail) {
                        if let habit = habitToOpen {
                            DetailView(viewModel: DetailViewModel(habit: habit))
                        }
                    }
                }
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
//                    sessionManager.syncAllHabitsToWatch()
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




