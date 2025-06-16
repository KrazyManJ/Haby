
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    
    @State private var mood: Mood = .Neutral
    
    init(viewModel: DailyViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    
                }
                Picker("Track today's mood", selection: $mood) {
                    ForEach(Mood.allCases, id: \.self) { value in
                        Text(value.emoji)
                            .tag(value)
                        }
                }
                .pickerStyle(.segmented)
                .padding()

                Text("Value: \(String(describing: mood))")
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Daily Habits")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing){
                NavigationLink(destination: OverviewView()) {
                    Text("Streak")
                }
            }
        }
        }
    }
}

#Preview {
    DailyView(viewModel: DailyViewModel())
}
