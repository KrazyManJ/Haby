import Foundation

protocol CategoryManaging {
    func fetchCategories() -> [String]
    func addCategory(_ category: String)
}
