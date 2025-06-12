
enum HabitType: Int16, CaseIterable, Identifiable  {
    var id: Self { self }
    
    case OnTime = 1
    case Deadline = 2
    case Amount = 3
    
    var name: String {
            String(describing: self)
        }
}
