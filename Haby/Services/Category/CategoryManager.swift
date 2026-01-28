import Foundation

final class CategoryManager: CategoryManaging {
    private let storageKey = "UserHabitCategories"
    private let defaults: UserDefaults // Store the reference
        
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func fetchCategories() -> [String] {
        var allCategories = defaults.stringArray(forKey: storageKey) ?? []
        let defaultCategories = HabitCategory.allCases.map { $0.name }
        if let saved = defaults.stringArray(forKey: storageKey) {
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
        
        defaults.set(current, forKey: storageKey)
    }
}
