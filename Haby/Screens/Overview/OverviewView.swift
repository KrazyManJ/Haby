

import SwiftUI

struct OverviewView: View {
    @State var viewModel = OverviewViewModel()
    
    var body: some View {
        ScrollView {
            VStack{
                Image(systemName: "flame").font(.system(size: 80)).foregroundColor(.orange).padding([.top],32)
                Text("Your streak is")
                Text("\(viewModel.state.streak) day\(viewModel.state.streak > 1 ? "s" : "")").font(.system(size: 48))
                FSCalendarView(
                    selectedDate: Binding(
                        get: {
                            viewModel.state.selectedDateData?.date
                        },
                        set: {
                            if let date = $0 {
                                viewModel.selectDate(date: date)
                            }
                            else {
                                viewModel.selectDate(date: nil)
                            }
                        }
                    ),
                    highlightedDates: $viewModel.state.completedDates,
                    moodRecords: viewModel.state.moodRecords
                )
                    .frame(height: 300)
                    .padding()
                Text("Steps Today: \(Int(viewModel.state.stepsToday))")
                                .font(.title)
                StepsChart(data: viewModel.state.monthlySteps)
            }
        }.toolbar(.hidden, for: .tabBar)
        .background(Color.background)
        .onAppear {
            viewModel.loadCompletedDates()
        }
        .sheet(
            isPresented: Binding(
                get: {
                    viewModel.state.selectedDateData != nil
                }, set: { val in
                    if !val {
                        viewModel.selectDate(date: nil)
                    }
                }
            ),
            content:{
                DayDetails(
                    viewModel: $viewModel,
                    selectedDateData: viewModel.state.selectedDateData!
                )
                .presentationDetents([.fraction(0.3), .medium, .large])
            }
        )
    }
}

#Preview {
    OverviewView()
}
