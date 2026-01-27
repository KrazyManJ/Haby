import SwiftUI

struct AnimatedCount: View, Animatable {
    var value: Float
    
    var animatableData: Float {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        Text(value.formatted(.number.precision(.fractionLength(0...2))))
    }
}
