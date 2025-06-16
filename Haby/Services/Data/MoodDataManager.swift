import UIKit

extension CoreDataManager {
    func getMoodRecordByDate(date: Date) -> MoodRecordEntity? {
        return fetchOne(
            predicate: NSPredicate(format: "date = %@",date as NSDate)
        )
    }
}
