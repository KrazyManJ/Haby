import SwiftUI

fileprivate extension Date {
    func dayOrdinal() -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        
        switch day {
        case 11, 12, 13: return "\(day)th"
        default:
            switch day % 10 {
            case 1: return "\(day)st"
            case 2: return "\(day)nd"
            case 3: return "\(day)rd"
            default: return "\(day)th"
            }
        }
    }
    
    func toOverviewString() -> String {
        let month = self.formatted(.dateTime.month(.wide))
        return "\(self.dayOrdinal()) \(month) Overview"
    }
}


struct OverviewDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var selectedDateData: SelectedDateData
    
    var habitsCount: Int { selectedDateData.habitsForDate.count }
    var completedHabits: Int {
        selectedDateData.habitsForDate
            .filter { habit in
                let record = selectedDateData.habitRecords.first { $0.habitDefinition.id == habit.id }
                return record?.isSatisfied ?? false
            }
            .count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    if let mood = selectedDateData.mood {
                        Image(mood.symbolResource)
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 48)
                            .foregroundStyle(.accent)
                    } else {
                        Image(systemName: "circle.dotted")
                            .font(.system(size: 48))
                            .foregroundStyle(.accent)
                    }
                    Text(selectedDateData.mood?.id ?? "Non-specified")
                        .bold()
                    Text("\(completedHabits)/\(habitsCount) Completed")
                        .foregroundStyle(.textSecondary)
                        .font(.footnote)
                }
                .padding([.vertical], 32)
                LazyVStack {
                    ForEach(selectedDateData.habitsForDate) { habit in
                        Card(cornerRadius: 8) {
                            HStack {
                                Image(systemName: habit.icon)
                                VStack(alignment: .leading) {
                                    Text(habit.name)
                                        .bold()
                                    Text(habit.data.type.name)
                                        .font(.caption)
                                        .foregroundStyle(.textSecondary)
                                }
                                Spacer()
                                
                                let record = selectedDateData.habitRecords.first { $0.habitDefinition.id == habit.id }
                                let isSatisfied = record?.isSatisfied ?? false
                                
                                Text(isSatisfied ? "Completed" : "Incompleted")
                                    .if(isSatisfied) { $0.foregroundStyle(.brandSecondary) }
                                    .if(!isSatisfied) { $0.foregroundStyle(.destructive) }
                            }
                            .padding(8)
                            .padding([.horizontal], 8)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(selectedDateData.date.toOverviewString())
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.accent)
                            .font(.caption)
                    }
                }
            }
            .padding([.horizontal])
        }
        .presentationDetents([.medium])
        .presentationBackground(.backgroundPrimary)
        
    }
}

#Preview {
    
    @Injected var dataManager: DataManaging
    
    let date = Date().onlyDate
    
    NavigationStack{}
        .sheet(isPresented: .constant(true)) {
            OverviewDetailSheet(
                selectedDateData: SelectedDateData(
                    date: date,
//                    mood: dataManager.getMoodRecordByDate(date: date)?.toModel().mood,
                    mood: nil,
                    habitRecords: dataManager.getRecordsByDate(date: date),
                    habitsForDate: dataManager.getHabitsForDate(date: date).filter { date.nextDay > $0.creationDate }
                )
            )
        }
        .preferredColorScheme(.dark)
        .foregroundStyle(.textPrimary)
}
