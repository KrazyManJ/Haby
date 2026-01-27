
import SwiftUI

struct Subtitle: View {
    
    @Localizable var title: String
    
    init(_ title: String) {
        self._title = Localizable(wrappedValue: title)
    }
    
    var body: some View {
        Text(title)
            .padding(.horizontal, 32)
            .padding([.top], 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title3).bold()
    }
}

#Preview {
    Subtitle("Title")
}
