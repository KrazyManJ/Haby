import SwiftUI

struct Card<Content: View>: View {
    
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack { content }
            .background(
                RoundedRectangle(cornerRadius: 16)
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
