import SwiftUI

struct DetailView: View {
    @State private var viewModel: DetailViewModel
    @State private var isAddingSheetPresented = false
    @State private var isAddEditHabitSheetPresented = false
    
    var habit: HabitDefinition {
        return viewModel.state.habit
    }
   
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }
    
    private var percentageOfCompletion: CGFloat { CGFloat(min(viewModel.state.currentAmount / Double(viewModel.state.goalAmount), 1.0)) }
    
    private var progressBarOpacity: CGFloat { percentageOfCompletion * 0.7 + 0.3 }
    
    var habitDetailTop: some View {
        VStack{
            //Spacer()
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [.brandPrimary.opacity(0.15), .clear]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 200
                )
                .ignoresSafeArea()
                VStack(alignment: .center, spacing: 20){
                    Image(systemName: habit.icon)
                        .foregroundStyle(.textPrimary)
                        .font(.system(size: 80))
                    Text(habit.name)
                        .foregroundStyle(.textPrimary)
                        .font(.largeTitle)
                    Text("\(habit.data.type.name) • \(habit.data.details.frequency.name)")
                        .foregroundStyle(.textSecondary)
                }
            }
        }
    }
    
    var body: some View {
        VStack{
            habitDetailTop
            if (habit.data.type == .Amount){
                VStack(alignment: .center, spacing: 20){
                    if(habit.data.type == .Amount){
                        VStack{
                            HStack {
                                Text("Progress:")
                                    .foregroundStyle(.textSecondary)
                                    .font(.subheadline)
                                Spacer()
                                Text(viewModel.state.status.progressString)
                                    .foregroundStyle(.textPrimary)
                                    .font(.subheadline).bold()
                            }
                            .padding([.leading, .trailing])
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
                            .padding()
                        }
                    }
                Spacer()
                Button{
                    isAddingSheetPresented = true
                } label: {
                    HStack{
                        Text("Add to progress")
                            .padding(8)
                            .frame(maxWidth: .infinity)
                    }
                }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.textPrimary)
                    .padding()
                    .buttonStyle(.bordered)
                    .tint(.brandSecondary)
                }
            } else {
                VStack{
                    HStack {
                        Text("Next completion in: ")
                            .foregroundStyle(.textSecondary)
                            .font(.subheadline)
                        Spacer()
                        Text(viewModel.state.status.requirementString)
                            .foregroundStyle(viewModel.state.status.isOverdue ? .destructive : .textPrimary)
                            .font(.subheadline).bold()
                    }
                    .padding()
                    Spacer()
                    CheckHabitButton(
//                        isChecked: viewModel.state.status.isCompleted
                        isChecked: viewModel.state.record != nil,
                        onToggle: {
                            viewModel.checkHabit(habit: viewModel.state.habit)
                            viewModel.getHabitRecord()
                        }
                    )
                    .padding()
                }
            }
        }
        .background(.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing){
                Button("Edit", systemImage: "pencil"){
                    isAddEditHabitSheetPresented = true
                }
                .tint(.textPrimary)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(
            isPresented: $isAddEditHabitSheetPresented,
            onDismiss: {
                viewModel.refreshHabit()
            }
        ) {
            NavigationStack {
                AddEditHabitView(viewModel: AddEditHabitViewModel(habit: habit))
            }
        }
        .sheet(isPresented: $isAddingSheetPresented) {
            AddToGoalHabitSheet(
                fraction: viewModel.state.goalAmount/20,
                onAdd: { addedAmount in
                    viewModel.addToAmountHabit(
                        habit: viewModel.state.habit,
                        addedAmount: addedAmount
                    )
                }
            )
        }
        .onAppear(){
            viewModel.refreshHabit()
        }
    }
}


