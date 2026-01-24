import SwiftUI

struct CornerShape: Shape {
    var radius: CGFloat = 8
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addArc(
            center: CGPoint(x: rect.width, y: rect.height),
            radius: rect.width,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}



struct Timeline: View {
    
    enum Variant {
        case Habit
        case FadeIn
        case FadeOut
    }
    
    var variant: Variant = .Habit
    
    private let cornerRadius: CGFloat = 8
    
    var body: some View {
        switch variant {
        case .Habit:
            habitVariant
        case .FadeIn:
            Rectangle()
                .fill(.textOnPrimary)
                .frame(width: 4, height: 16)
                .mask(
                    LinearGradient(
                        colors: [.clear, .textOnPrimary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        case .FadeOut:
            Rectangle()
                .fill(.textOnPrimary)
                .frame(width: 4, height: 16)
                .mask(
                    LinearGradient(
                        colors: [.clear, .textOnPrimary],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
        }
    }
    
    var habitVariant: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.textOnPrimary)
                .frame(width: 4, height: 56)
            Rectangle()
                .fill(.textOnPrimary)
                .frame(width: 24, height: 4)
                .overlay(alignment: .topLeading) {
                    CornerShape(radius: cornerRadius)
                        .fill(.textOnPrimary)
                        .frame(width: cornerRadius, height: cornerRadius)
                        .rotationEffect(.degrees(-90))
                        .offset(y: -cornerRadius)
                }
                .overlay(alignment: .bottomLeading) {
                    CornerShape(radius: cornerRadius)
                        .fill(.textOnPrimary)
                        .frame(width: cornerRadius, height: cornerRadius)
                        .offset(y: cornerRadius)
                }
        }
    }
}

#Preview {
    Timeline()
        .padding()
        .background(.backgroundPrimary)
        .preferredColorScheme(.dark)
}
