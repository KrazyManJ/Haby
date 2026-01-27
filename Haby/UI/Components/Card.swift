import SwiftUI

struct Card<Content: View>: View {
    
    var cornerRadius: CGFloat = 16
    
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack { content }
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Colors.BackgroundSecondary)
            )
    }
}

#Preview() {
    Card {
        Text("Content").padding()
    }
        .padding()
        .background(Colors.BackgroundPrimary)
}
