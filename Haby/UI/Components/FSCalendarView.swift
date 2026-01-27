import SwiftUI
import FSCalendar

fileprivate enum RangePosition {
    case none
    case single
    
    case start
    case end
    case middle
    
    case startOfRow
    case endOfRow
    case fullRow
}

fileprivate class ConnectedRangeCell: FSCalendarCell {
    private weak var highlightLayer: CAShapeLayer?

    var rangePosition: RangePosition = .none {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.brandPrimary.withAlphaComponent(0.1).cgColor
        layer.actions = ["path": NSNull()]
        self.contentView.layer.insertSublayer(layer, below: self.titleLabel.layer)
        self.highlightLayer = layer
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: ConnectedRangeCell, previousTraitCollection) in
                self.highlightLayer?.fillColor = UIColor.brandPrimary.withAlphaComponent(0.3).cgColor
            }
        }
    }
    
    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let highlightLayer = highlightLayer else { return }
        
        if rangePosition == .none {
            highlightLayer.isHidden = true
            return
        }
        
        highlightLayer.isHidden = false
        
        let diameter = min(bounds.width, bounds.height) * 0.85
        let yOffset = (bounds.height - diameter) / 2 - 3
        let xOffset = (bounds.width - diameter) / 2
        
        let fullRadius = diameter / 2
        let softRadius: CGFloat = 8.0
        
        let path = UIBezierPath()
        
        switch rangePosition {
        case .single:
            let rect = CGRect(x: xOffset, y: yOffset, width: diameter, height: diameter)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: fullRadius))
            
        case .start:
            let rect = CGRect(x: xOffset, y: yOffset, width: bounds.width - xOffset, height: diameter)
            path.append(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: fullRadius, height: fullRadius)))
            
        case .end:
            let rect = CGRect(x: 0, y: yOffset, width: xOffset + diameter, height: diameter)
            path.append(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: fullRadius, height: fullRadius)))
            
        case .middle:
            let rect = CGRect(x: 0, y: yOffset, width: bounds.width, height: diameter)
            path.append(UIBezierPath(rect: rect))
            
        case .startOfRow:
            let rect = CGRect(x: 0, y: yOffset, width: bounds.width, height: diameter)
            path.append(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: softRadius, height: softRadius)))

        case .endOfRow:
            let rect = CGRect(x: 0, y: yOffset, width: bounds.width, height: diameter)
            path.append(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: softRadius, height: softRadius)))
            
        case .fullRow:
            let rect = CGRect(x: 0, y: yOffset, width: bounds.width, height: diameter)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: softRadius))
            
        case .none:
            break
        }

        highlightLayer.path = path.cgPath
    }
}

struct FSCalendarView: UIViewRepresentable {
    let selectedDate: Date?
    let highlightedDates: Set<Date>
    let moodRecords: [MoodRecord]
    let onDateSelect: (Date) -> Void

    internal class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.onDateSelect(date)
        }
        
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! ConnectedRangeCell
            
            if parent.highlightedDates.contains(date) {
                
                let calendar = Calendar.current
                let previousDate = calendar.date(byAdding: .day, value: -1, to: date)!
                let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
                
                let isPrevHighlighted = parent.highlightedDates.contains(previousDate)
                let isNextHighlighted = parent.highlightedDates.contains(nextDate)
                
                let weekday = calendar.component(.weekday, from: date)
                let isMonday = (weekday == 2)
                let isSunday = (weekday == 1)
                
                let connectsLeft = isPrevHighlighted && !isMonday
                let connectsRight = isNextHighlighted && !isSunday
                
                let continuesFromPrevWeek = isPrevHighlighted && isMonday
                let continuesToNextWeek = isNextHighlighted && isSunday
                
                if connectsLeft && connectsRight {
                    cell.rangePosition = .middle
                }
                else if !connectsLeft && connectsRight {
                    if continuesFromPrevWeek {
                         cell.rangePosition = .startOfRow
                    } else {
                         cell.rangePosition = .start
                    }
                }
                else if connectsLeft && !connectsRight {
                    if continuesToNextWeek {
                        cell.rangePosition = .endOfRow
                    } else {
                        cell.rangePosition = .end
                    }
                }
                else {
                    if continuesFromPrevWeek && continuesToNextWeek {
                        cell.rangePosition = .fullRow
                    } else if continuesFromPrevWeek {
                        cell.rangePosition = .endOfRow
                    } else if continuesToNextWeek {
                        cell.rangePosition = .startOfRow
                    } else {
                        cell.rangePosition = .single
                    }
                }
            } else {
                cell.rangePosition = .none
            }
            
            cell.accessibilityIdentifier = VariableAccessibilityTag.FSCalendarView_Cell(date: date).rawValue
            cell.isAccessibilityElement = true
            return cell
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
        
        calendar.register(ConnectedRangeCell.self, forCellReuseIdentifier: "cell")
        
        calendar.appearance.titleDefaultColor = Colors.TextPrimary.ui
        calendar.appearance.titlePlaceholderColor = Colors.TextSecondary.ui
        calendar.appearance.weekdayTextColor = Colors.Primary.ui
        calendar.appearance.todayColor = .brandSecondary
        calendar.appearance.headerTitleColor = .brandPrimary
        calendar.appearance.selectionColor = .brandPrimary
        calendar.appearance.titleSelectionColor = .textOnPrimary
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        context.coordinator.parent = self
        
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
