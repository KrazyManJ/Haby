
import SwiftUI

struct AddHabitToolbarItem : ToolbarContent {
    
    @Binding var isAddEditHabitViewPresented: Bool
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing){
            Button(action: {
                isAddEditHabitViewPresented = true
            }) {
                Label("New Habit", systemImage: "plus.circle")
                    .labelStyle(.iconOnly)
            }
        }
    }
}
