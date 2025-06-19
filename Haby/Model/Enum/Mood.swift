
enum Mood: Int16, CaseIterable, Identifiable{
    case Joyous
    case Happy
    case Neutral
    case Sad
    case Angry
    
    var id: String { String(describing: self) }
    
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
