import SwiftUI

@propertyWrapper
struct Localizable {
    private var key: String

    init(wrappedValue: String) {
        self.key = wrappedValue
    }

    var wrappedValue: String {
        get {
            NSLocalizedString(key, comment: "")
        }
        set {
            key = newValue
        }
    }
}
