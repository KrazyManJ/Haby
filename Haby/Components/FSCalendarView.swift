import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    @Binding var highlightedDates: Set<Date>
    var moodRecords: [MoodRecord]

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }

        func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
            let calendar = Calendar.current
            if let record = parent.moodRecords.first(where: {
                calendar.isDate($0.date, inSameDayAs: date)
            }) {
                return record.mood.emoji
            }
            return nil
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                    return nil
                }
            for highlighted in parent.highlightedDates {
                if calendar.isDate(date, inSameDayAs: highlighted) {
                    return UIColor.systemBlue.withAlphaComponent(0.3)
                }
            }
            return nil
        }

        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                return nil
            }
            for highlighted in parent.highlightedDates {
                if calendar.isDate(date, inSameDayAs: highlighted) {
                    return UIColor.systemBlue
                }
            }
            return nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.firstWeekday = 2
        
        calendar.appearance.subtitleOffset = CGPoint(x: 0, y: 2)
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        let calendar = Calendar.current

        if let selected = selectedDate {
            // Only select the date if it's not already selected
            if let currentSelected = uiView.selectedDate,
               !calendar.isDate(currentSelected, inSameDayAs: selected) {
                uiView.select(selected)
            } else if uiView.selectedDate == nil {
                uiView.select(selected)
            }
        } else {
            // Deselect current selection if selectedDate is nil
            if let currentSelected = uiView.selectedDate {
                uiView.deselect(currentSelected)
            }
        }
    }
}
