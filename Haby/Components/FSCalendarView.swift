import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
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
        // Optionally update the calendar here
    }
}
