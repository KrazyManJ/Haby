import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    @Binding var highlightedDates: Set<Date>

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
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
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        
    }
}
