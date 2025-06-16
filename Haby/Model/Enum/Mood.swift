
enum Mood: Int16, CaseIterable {
    case Joyous
    case Happy
    case Neutral
    case Sad
    case Angry
    
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
