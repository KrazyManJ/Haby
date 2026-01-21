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
                            .frame(height: 32)
                            .foregroundStyle(Colors.TextPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .if(selectedMood == mood) {
                                $0.background(Colors.TextSecondary)
                            }
//                        Text(mood.emoji)
//                            .font(.system(size: 32))
//                            .frame(height: 64)
//                            .frame(maxWidth: .infinity)
//                            .if(selectedMood == mood) { $0.background(Colors.TextSecondary) }
                            
                    }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(8)
        }
    }
}

#Preview {
    @Previewable @State var mood: Mood = .Neutral
    
    MoodPickerView(selectedMood: $mood).padding()
}
