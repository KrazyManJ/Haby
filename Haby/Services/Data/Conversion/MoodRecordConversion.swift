
extension MoodRecord : EntityConverting {
    func toEntity() -> MoodRecordEntity {
        let dataManaging: Injected<DataManaging> = .init()
        let entity = MoodRecordEntity(context: dataManaging.wrappedValue.context)
        
        entity.id = id
        entity.date = date
        entity.mood = mood.rawValue
        
        return entity
    }
}

extension MoodRecordEntity : ModelConverting {
    func toModel() -> MoodRecord {
        return MoodRecord(
            id: id!,
            date: date!,
            mood: Mood(rawValue: mood)!
        )
    }
}

