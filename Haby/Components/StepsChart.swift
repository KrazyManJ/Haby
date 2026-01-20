import Charts
import SwiftUI

struct StepsChart: View {
    var data: [StepData]

    var body: some View {
        VStack(alignment: .leading){
            Text("Steps").foregroundStyle(.white)
            Chart(data) {
                BarMark(
                    x: .value("Date", $0.date),
                    y: .value("Steps", $0.steps)
                )
                .foregroundStyle(.white)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white)
                }
            }
            HStack{
                VStack(alignment: .leading){
                    Text("Your Goal").foregroundStyle(.white)
                    Text("goal").foregroundStyle(.white)
                }
                VStack(alignment: .leading){
                    Text("Your Average").foregroundStyle(.white)
                    Text("avg").foregroundStyle(.white)
                }
            }
        }
        .frame(height: 220)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.Primary)
        )
        .padding()
        
    }
}
