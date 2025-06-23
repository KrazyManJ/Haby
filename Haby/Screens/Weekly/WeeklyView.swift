

import SwiftUI

struct WeeklyView: View {
    @State private var viewModel: WeeklyViewModel
    
    init(viewModel: WeeklyViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    Text("habit")
                    Text("habit")
                    Text("habit")
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
        }
    }
}

#Preview {
    //WeeklyView()
}
