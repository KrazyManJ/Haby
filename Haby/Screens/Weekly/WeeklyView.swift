

import SwiftUI

struct WeeklyView: View {
    @State private var viewModel: WeeklyViewModel
    
    init(viewModel: WeeklyViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
                    WeekTable(viewModel: $viewModel)
//                    LazyVStack(spacing: 0) {
//                        ForEach(viewModel.state.habits.filter { $0.type != .Amount}) { habit in
//                            WeekTable(
//                                viewModel: $viewModel, habit: habit
//                            )
//                        }
//                        Spacer(minLength: 0)
//                    }
//                    .padding()
                    
                    if !viewModel.state.amountHabits.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.state.amountHabits) { habit in
                                WeeklyGoalProgressBar(
                                    viewModel: $viewModel, habit: habit
                                )
                                .padding(8)
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.Secondary)
                        )
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Weekly Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    NavigationLink(destination: OverviewView()) {
                        Button("Streak", systemImage: "flame"){}
                    }
                }
            }
            .tint(.orange)
            .onAppear {
                viewModel.getWeekHabits()
            }
            .background(Color.Background)
        }
    }
}



#Preview {
    //WeeklyView()
}
