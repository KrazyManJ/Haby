
import Charts
import SwiftUI

struct DistanceChart: View {
    var data: [DistanceData]

    var body: some View {
            Chart(data) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Kilometers", entry.kilometers)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
                .symbol(Circle())
            }
            .chartYAxisLabel("km")
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            .frame(height: 220)
    }
}
