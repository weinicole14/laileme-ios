import Foundation
import SwiftData

@Model
final class SecretRecord {
    var id: UUID
    var date: Date
    var hadSex: Bool
    var protection: String   // none, condom, pill, iud, safe_period, other
    var feeling: Int          // 0=未评, 1-5星
    var mood: String
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date,
        hadSex: Bool = false,
        protection: String = "",
        feeling: Int = 0,
        mood: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.hadSex = hadSex
        self.protection = protection
        self.feeling = feeling
        self.mood = mood
        self.notes = notes
    }
}
