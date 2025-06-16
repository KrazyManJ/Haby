
import SwiftUI

struct DailyView: View {
    @State private var viewModel: DailyViewModel
    
    // TODO delete later
    var mood = ["apple", "banana", "orange"]
    @State private var selectedMood: String = "banana"
    
    init(viewModel: DailyViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    
                }
                Picker("Track today's mood", selection: $selectedMood) {
                    Text("😁").tag(0)
                    Text("😊").tag(1)
                    Text("😐").tag(2)
                    Text("☹️").tag(3)
                    Text("😠").tag(4)
                }
                .pickerStyle(.segmented)

            Text("Value: \(selectedMood)")
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
