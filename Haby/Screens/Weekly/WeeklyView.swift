

import SwiftUI

struct WeeklyView: View {
    @State private var viewModel: WeeklyViewModel
    
    init(viewModel: WeeklyViewModel = WeeklyViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView {
                    Text("Week Timeline")
                        .padding(.horizontal, 32)
                        .padding([.top], 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3).bold()
                    if !viewModel.state.habits.filter({ $0.type != .Amount }).isEmpty {
                        
                        WeekTable(viewModel: $viewModel)
                            .padding()
                    }  else {
                        Text("No weekly habits!").italic().foregroundColor(.gray)
                            .padding(.vertical,32)
                    }
                    
                    Text("Goals")
                        .padding(.horizontal, 32)
                        .padding([.top], 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3).bold()
                    if !viewModel.state.amountHabits.isEmpty {
                        Card {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.state.amountHabits) { habit in
                                    WeeklyGoalProgressBar(
                                        viewModel: $viewModel, habit: habit
                                    )
                                    .padding(8)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding()
                        }
                        .frame(minHeight: 100)
                        .padding()
                    }  else {
                        Text("No goal habits for this week!")
                            .italic().foregroundColor(Color.gray).padding(.vertical,32)
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
            .background(Colors.BackgroundPrimary)
        }
    
//        .tint(.Primary)
    }
}



#Preview {
    //WeeklyView()
}
