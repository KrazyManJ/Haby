import SwiftUI

struct MoodPickerView: View {
    @Binding var selectedMood: Mood
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        Text(mood.emoji)
                            .font(.system(size: 30)) // Emoji size
                            .frame(width: 60, height: 60)
                            .background(selectedMood == mood ? Color.Secondary : Color.Secondary.opacity(0.0))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                }
            }
            .padding(8)
            .background(Color.Primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
