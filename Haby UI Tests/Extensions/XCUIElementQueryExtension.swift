import XCTest

extension XCUIElementQuery {
    subscript(_ tag: AccessibilityTag) -> XCUIElement {
        self[tag.rawValue]
    }
    subscript(_ tag: VariableAccessibilityTag) -> XCUIElement {
        self[tag.rawValue]
    }
}
