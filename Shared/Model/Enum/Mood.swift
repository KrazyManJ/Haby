
import SwiftUI

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
    
    var symbolResource: String {
        switch self {
            case .Joyous: "lucide-laugh"
            case .Happy: "lucide-smile"
            case .Neutral: "lucide-meh"
            case .Sad: "lucide-frown"
            case .Angry: "lucide-angry"
        }
    }
}
