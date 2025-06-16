
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    
    init(viewModel: DailyViewModel) {
        self.viewModel = viewModel
        viewModel.getTodayMood()
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    
                }
                Picker("Track today's mood", selection: Binding(
                    get: {
                        viewModel.state.todayMoodData.mood
                    },
                    set: {
                        viewModel.state.todayMoodData.mood = $0
                        viewModel.updateMood(mood: $0)
                    }
                )) {
                    ForEach(Mood.allCases, id: \.self) { value in
                        Text(value.emoji).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Text("Value: \(String(describing: viewModel.state.todayMoodData.mood))")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Daily Habits")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing){
                    NavigationLink(destination: OverviewView()) {
                        Text("Streak")
                    }
                }
            }.onAppear {
                if !viewModel.isTodayMoodSaved() {
                    print("Not saved")
                    viewModel.updateMood(mood: .Neutral)
                }
            }
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
