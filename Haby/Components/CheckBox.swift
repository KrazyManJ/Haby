import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {

            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 25, height: 25)
                .cornerRadius(5.0)
                .overlay {
                    if (configuration.isOn){
                        Image(systemName: "checkmark")
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
    
    var body: some View {
        Toggle(isOn: $isOn){}
        .toggleStyle(CheckboxToggleStyle())
    }
}
