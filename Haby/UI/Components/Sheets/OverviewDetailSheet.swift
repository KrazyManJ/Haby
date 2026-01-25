import SwiftUI

struct OverviewDetailSheet: View {
    var selectedDateData: SelectedDateData
    
    var moodLabel: String {
        if let mood = selectedDateData.mood {
            return String(describing: mood)
        }
        return "Unknown"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                VStack {
                    
                }
            }
        }
        .foregroundStyle(.white)
        .presentationDetents([.fraction(0.3), .medium, .large])
        .presentationBackground(.backgroundPrimary)
    }
}
