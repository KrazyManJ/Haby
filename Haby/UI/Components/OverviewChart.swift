import Charts
import SwiftUI

struct OverviewChart: View {
    var data: [HealthDataPoint]
    var valueType: AmountUnit

    var body: some View {
        VStack(alignment: .leading){
            Text("habit name")
            Chart(data) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value(valueType.name, entry.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
                .symbol(Circle())
            }
            .chartYAxisLabel(valueType.abbreviation)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            HStack{
                VStack(alignment: .leading){
                    Text("Your Goal")
                    Text("goal \(valueType.abbreviation)")
                }
                VStack(alignment: .leading){
                    Text("Your Average")
                    Text("avg \(valueType.abbreviation)")
                }
            }
        }
        .frame(height: 220)
    }
        
}
