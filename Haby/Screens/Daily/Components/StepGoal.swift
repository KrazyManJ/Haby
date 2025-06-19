
import SwiftUI

// TODO implement in dailyGoalProgressBar!!
// delete later
struct StepProgressBar: View {
    var steps: Double
    var goal: Double

    var progress: Double {
        min(steps / goal, 1.0)
    }

    var progressColor: Color {
            switch progress {
            case 0..<0.5: return .red
            case 0.5..<1.0: return .orange
            default: return .green
            }
        }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)

                RoundedRectangle(cornerRadius: 8)
                    .fill(progressColor)
                    .frame(width: geo.size.width * progress, height: 20)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 20)
    }
}

