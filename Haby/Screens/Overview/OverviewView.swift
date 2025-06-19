

import SwiftUI

struct OverviewView: View {
    @StateObject var viewModel = OverviewViewModel()
    @State private var selectedDate: Date?
    
    var body: some View {
        ScrollView {
            VStack{
                Image(systemName: "flame").font(.system(size: 80)).foregroundColor(.orange)
                FSCalendarView(selectedDate: $selectedDate)
                    .frame(height: 300)
                    .padding()
//                if let date = selectedDate {
//                    Text("Selected: \(date.formatted(date: .abbreviated, time: .omitted))")
//                }
                Text("Steps Today: \(Int(viewModel.stepsToday))")
                                .font(.title)
                StepsChart(data: viewModel.monthlySteps)
            }
        }.toolbar(.hidden, for: .tabBar)
            .background(Color.background)
            .onAppear {
                viewModel.loadCompletedDates()
                viewModel.completedDates.forEach { print($0) }
            }
    }
}

#Preview {
    OverviewView()
}
