import SwiftUI

struct CategoryPicker: View {
    @Binding var habitCategories: [String]
    @Binding var selection: String
    
    @State private var customText: String = ""
    
    var body: some View {
        Group {
            Picker("Category", selection: $selection) {
                Text("Select...").tag("")
                ForEach(habitCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
                if !selection.isEmpty && !habitCategories.contains(selection) {
                    Text("\(selection)")
                        .tag(selection)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selection) {
                if habitCategories.contains(selection) {
                    customText = ""
                } else {
                    customText = selection
                }
            }
            
            HStack {
                TextField("Or create new...", text: $customText)
                    .autocorrectionDisabled()
                    .onChange(of: customText) {
                        if !customText.isEmpty {
                            selection = customText
                        }
                    }
            }
        }
        .listRowBackground(Colors.BackgroundSecondary)
        .onAppear {
            if !selection.isEmpty && !habitCategories.contains(selection) {
                customText = selection
            }
        }
    }
}
