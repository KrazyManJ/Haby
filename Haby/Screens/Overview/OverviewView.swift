

import SwiftUI

struct OverviewView: View {
    @State var viewModel = OverviewViewModel()
    @State private var selectedDate: Date?
    
    var body: some View {
        ScrollView {
            VStack{
                Image(systemName: "flame").font(.system(size: 80)).foregroundColor(.orange).padding([.top],32)
                Text("Your streak is")
                Text("\(viewModel.state.streak) day\(viewModel.state.streak > 1 ? "s" : "")").font(.system(size: 48))
                FSCalendarView(
                    selectedDate: $selectedDate,
                    highlightedDates: $viewModel.state.completedDates,
                    moodRecords: viewModel.state.moodRecords
                )
                    .frame(height: 300)
                    .padding()
//                if let date = selectedDate {
//                    Text("Selected: \(date.formatted(date: .abbreviated, time: .omitted))")
//                }
                Text("Steps Today: \(Int(viewModel.state.stepsToday))")
                                .font(.title)
                StepsChart(data: viewModel.state.monthlySteps)
            }
        }.toolbar(.hidden, for: .tabBar)
        .background(Color.background)
        .onAppear {
            viewModel.loadCompletedDates()
        }
    }
}

#Preview {
    OverviewView()
}
