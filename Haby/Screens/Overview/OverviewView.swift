

import SwiftUI
import LRStreakKit

struct OverviewView: View {
    var body: some View {
        VStack{
            Image(systemName: "flame").font(.system(size: 80)).foregroundColor(.orange)
            Text("tvuj streak brasko")
            StreakView()
        }
    }
}

#Preview {
    OverviewView()
}



//struct StreakCalendarView: View {
//    @EnvironmentObject var streak: StreakManager
//    @State private var selectedDate: Date = Date()
//    
//    private var daysInMonth: [Date] {
//        // Generate an array of dates for the current month
//    }
//    
//    private func isStreakDay(_ date: Date) -> Bool {
//        // Determine if the given date is part of the current streak
//    }
//    
//    var body: some View {
//        VStack {
//            // Calendar header with month and navigation buttons
//            
//            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
//                ForEach(daysInMonth, id: \.self) { date in
//                    Text("\(Calendar.current.component(.day, from: date))")
//                        .frame(width: 30, height: 30)
//                        .background(isStreakDay(date) ? Color.green : Color.clear)
//                        .cornerRadius(5)
//                        .onTapGesture {
//                            // Handle date selection
//                        }
//                }
//            }
//        }
//    }
//}
