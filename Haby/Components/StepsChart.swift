import Charts
import SwiftUI

struct StepsChart: View {
    var data: [StepData]

    var body: some View {
        Card {
            VStack(alignment: .leading){
                Text("Steps")
                Chart(data) {
                    BarMark(
                        x: .value("Date", $0.date),
                        y: .value("Steps", $0.steps)
                    )
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Colors.TextPrimary.opacity(0.3))
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(Colors.TextPrimary.opacity(0.3))
                        AxisValueLabel()
                    }
                }
                HStack{
                    VStack(alignment: .leading){
                        Text("Your Goal")
                        Text("goal")
                    }
                    VStack(alignment: .leading){
                        Text("Your Average")
                        Text("avg")
                    }
                }
            }
            .frame(height: 220)
            .padding()
        }
        .padding()
    }
}
