import Foundation

extension Float {
    var cleanString: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
