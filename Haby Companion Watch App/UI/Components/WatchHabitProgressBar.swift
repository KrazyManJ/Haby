import SwiftUI

struct HabitProgressBar: View {
    let current: Float
    let target: Float
    let color: Color
    
    var progress: Float {
        guard target > 0 else { return 0 }
        return min(max(current / target, 0), 1)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                        .animation(.bouncy, value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal)
    }
}
