import Foundation

final class CategoryManager: CategoryManaging {
    private let storageKey = "UserHabitCategories"
    
    func fetchCategories() -> [String] {
        var allCategories = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        let defaultCategories = HabitCategory.allCases.map { $0.name }
        if let saved = UserDefaults.standard.stringArray(forKey: storageKey) {
            return saved
        }
        
        let defaults = HabitCategory.allCases.map { $0.name }
        return defaults
    }
    
    func addCategory(_ category: String) {
        var current = fetchCategories()
        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty, !current.contains(trimmed) else { return }
        
        current.append(trimmed)
        current.sort()
        
        UserDefaults.standard.set(current, forKey: storageKey)
    }
}
