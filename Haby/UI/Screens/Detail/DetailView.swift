import SwiftUI

struct DetailView: View {
    @State private var viewModel: DetailViewModel
    //let status: HabitStatusHelper
    @State private var isAddingSheetPresented = false
    
    var habit: HabitDefinition {
        return viewModel.state.habit
    }
//    
//    var record: HabitRecord {
//        return viewModel.state.record
//    }
//    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
//        if (record.data.type.name == .Amount){
//            currentAmount = record.data
//        } else {
//            
//        }
    }
    
    
/*
    var currentAmount: Float
    var onAdd: (Float) -> Void
        
    private var goalAmount: Float {
        switch habit.data {
        case .Amount(let data):
            return data.amount
        default:
            return -1
        }
    }

    private var goalUnit: String {
        switch habit.data {
        case .Amount(let data):
            return data.unit.abbreviation
        default:
            return ""
        }
    }
    
    private var percentageOfCompletion: CGFloat { CGFloat(min(currentAmount / goalAmount, 1.0)) }
    
    private var progressBarOpacity: CGFloat { percentageOfCompletion * 0.7 + 0.3 }
*/
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [.brandPrimary.opacity(0.3), .clear]),
                center: .center,
                startRadius: 5,
                endRadius: 160
           )
            VStack(alignment: .center){
                Image(systemName: habit.icon)
                    .foregroundStyle(.textPrimary)
                    .font(.system(size: 80))
                Text(habit.name)
                    .foregroundStyle(.textPrimary)
                    .font(.largeTitle)
                Text("\(habit.data.type.name) • \(habit.data.details.frequency.name)")
                    .foregroundStyle(.textSecondary)
                if(habit.data.type == .Amount){
                    HStack {
                        Text("Progress:")
                            .foregroundStyle(.textSecondary)
                            .font(.subheadline)
                        Spacer()
                        // use habitstatushelper
                        Text("current value / requirement string")
                            .foregroundStyle(.textPrimary)
                            .font(.subheadline).bold()
                    }
                    /*
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.textOnPrimary)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.accent.opacity(progressBarOpacity))
                                .frame(width: geometry.size.width * percentageOfCompletion, height: 6)
                        }
                    }
                     */
                } else {
                    HStack {
                        Text("Next completion in: ")
                            .foregroundStyle(.textSecondary)
                            .font(.subheadline)
                        Spacer()
                        Text("placeholder")
                            .foregroundStyle(.textPrimary)
                            .font(.subheadline).bold()
                    }
                }
                if (habit.data.type == .Amount){
                    Button("Add to progress", systemImage: "plus"){
                        isAddingSheetPresented = true
                    }
                } else {
                    Button("Check habit"){
                        
                    }
                }
               
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing){
                
                NavigationLink(destination: AddEditHabitView(
                    viewModel: AddEditHabitViewModel(habit: habit)
                )) {
                    Button("Edit", systemImage: "pencil"){
                        
                    }
                }
                .tint(.textPrimary)
                 
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
//        .sheet(isPresented: $isAddingSheetPresented) {
//            AddToGoalHabitSheet(fraction: goalAmount/20, onAdd: onAdd)
//        }
//        .onAppear(){
//            viewModel.getHabitRecords()
//        }
    }
}


