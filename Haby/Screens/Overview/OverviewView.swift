

import SwiftUI
import LRStreakKit

struct OverviewView: View {
    @StateObject var viewModel = OverviewViewModel()
    
    var body: some View {
        VStack{
            Image(systemName: "flame").font(.system(size: 80)).foregroundColor(.orange)
            Text("tvuj streak brasko")
            StreakView()
            Text("Steps Today: \(Int(viewModel.stepsToday))")
                            .font(.title)
            StepsChart(data: viewModel.monthlySteps)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    OverviewView()
}
