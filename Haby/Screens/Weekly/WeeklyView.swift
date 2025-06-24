

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
                    LazyVStack(spacing: 0) {
                        //if !viewModel.state.timeHabits.isEmpty {
                        WeekTable(viewModel: $viewModel)
                        //}
                    }
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
                    .tint(.orange)
                }
            }
            
            .onAppear {
                viewModel.getWeekHabits()
            }
            .background(Color.Background)
        }
        .tint(.Primary)
    }
}



#Preview {
    //WeeklyView()
}
