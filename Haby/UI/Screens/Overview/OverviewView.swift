

import SwiftUI

struct OverviewView: View {
    @State var viewModel = OverviewViewModel()
    
    var body: some View {
        ScrollView {
            VStack{
                ZStack {
                    RadialGradient(
                        gradient: Gradient(colors: [.accent.opacity(0.1), .clear]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 128
                    )
                    VStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.accent)
                            .padding([.top],32)
                        Text("Your streak is...")
                            .foregroundStyle(.textSecondary)
                        Text("\(viewModel.state.streak) day\(viewModel.state.streak > 1 ? "s" : "")")
                            .font(.system(size: 48))
                            .bold()
                    }
                }
                
                FSCalendarView(
                    selectedDate: viewModel.state.selectedDateData?.date,
                    highlightedDates: viewModel.state.completedDates,
                    moodRecords: viewModel.state.moodRecords
                ) { date in
                    viewModel.selectDate(date: date)
                }
                .frame(height: 300)
                .padding()
                Text("Steps Today: \(Int(viewModel.state.stepsToday))")
                    .font(.title)
                StepsChart(data: viewModel.state.monthlySteps)
            }
        }.toolbar(.hidden, for: .tabBar)
        .background(Colors.BackgroundPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.loadCompletedDates()
        }
        .sheet(
            item: $viewModel.state.selectedDateData
        ) { dateData in
            OverviewDetailSheet(
                selectedDateData: dateData
            )
        }
    }
}

#Preview {
    OverviewView()
        .preferredColorScheme(.dark)
        .foregroundStyle(.textPrimary)
}
