
import SwiftUI

struct FloatTextField: View {
    @Binding var value: Float
    @Binding var rawText: String

    var body: some View {
        TextField("0", text: $rawText)
            .keyboardType(.decimalPad)
//            .multilineTextAlignment(.center)
//            .font(.system(size: 48, weight: .medium))
//            .frame(width: 120)
            .textFieldStyle(PlainTextFieldStyle())
            .onChange(of: rawText) { newValue in
                if let floatValue = Float(newValue) {
                    value = floatValue
                }
            }
    }
}

func isValidFloat(_ input: String) -> Bool {
    guard let float = Float(input) else { return false }
    return float > 0
}
