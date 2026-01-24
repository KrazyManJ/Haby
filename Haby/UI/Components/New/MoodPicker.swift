import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Mood
    
    var body: some View {
        Card {
            HStack(spacing: 0) {
                ForEach(Mood.allCases) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        Image(mood.symbolResource)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                            .foregroundStyle(Colors.TextPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .if(selectedMood == mood) {
                                $0.background(.textOnPrimary)
                            }
                    }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(4)
        }
    }
}

#Preview {
    @Previewable @State var mood: Mood = .Neutral
    
    MoodPickerView(selectedMood: $mood)
        .preferredColorScheme(.dark)
        .padding()
}
