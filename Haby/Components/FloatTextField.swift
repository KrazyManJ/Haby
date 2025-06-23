
import SwiftUI

struct FloatTextField: View {
    @Binding var value: Float
    @Binding var rawText: String

    var body: some View {
        TextField("0", text: $rawText)
            .keyboardType(.decimalPad)
            .textFieldStyle(PlainTextFieldStyle())
            .onChange(of: rawText) { newValue in
                let allowedChars = "0123456789."
                var filtered = newValue.filter { allowedChars.contains($0) }

                let dotCount = filtered.filter { $0 == "." }.count
                if dotCount > 1 {
                    filtered = String(filtered.dropLast())
                }

                if let dotIndex = filtered.firstIndex(of: ".") {
                    let afterDecimal = filtered[filtered.index(after: dotIndex)...]
                    if afterDecimal.count > 3 {
                        filtered = String(filtered.prefix(upTo: filtered.index(dotIndex, offsetBy: 4)))
                    }
                }

                rawText = filtered

                if let floatValue = Float(filtered) {
                    value = floatValue
                } else {
                    value = 0
                }
            }
    }
}


extension Float {
    var trimmedString: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

