
enum HabitFrequency: Int16, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    
    case Daily = 1
    case Weekly = 2
    
    var name: String {
        String(describing: self)
    }
}
