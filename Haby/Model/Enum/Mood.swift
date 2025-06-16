
enum Mood: CaseIterable {
    case Joyous, Happy, Neutral, Sad, Angry
    
    var emoji: String {
        switch self {
            case .Joyous : "😁"
            case .Happy : "😊"
            case .Neutral : "😐"
            case .Sad : "☹️"
            case .Angry : "😠"
        }
    }
}
