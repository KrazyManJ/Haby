import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    var isInvalid: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 4)
                .frame(width: 25, height: 25)
                .cornerRadius(5.0)
                .overlay {
                    if (configuration.isOn){
                        Image(systemName: isInvalid ? "xmark" : "checkmark")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }

            configuration.label
        }
    }
}

struct CheckBox: View {
    @Binding var isOn: Bool
    var isInvalid: Bool
    
    var body: some View {
        Toggle(isOn: $isOn){
            EmptyView()
        }
            .toggleStyle(CheckboxToggleStyle(isInvalid: isInvalid))
    }
}
