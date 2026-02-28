import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID
    var date: Date
    var mood: String
    var symptoms: String
    var notes: String
    // 身体状态
    var flowLevel: Int        // 0=未记录, 1=少, 2=中, 3=多
    var flowColor: String     // light_red, red, dark_red, brown, black
    var painLevel: Int        // 0=无, 1=轻微, 2=中等, 3=较重, 4=严重
    var breastPain: Int       // 0=无, 1=轻微, 2=明显, 3=严重
    var digestive: Int        // 0=正常, 1=轻微不适, 2=腹泻, 3=便秘
    var backPain: Int         // 0=无, 1=轻微, 2=明显, 3=严重
    var headache: Int         // 0=无, 1=轻微, 2=明显, 3=严重
    var fatigue: Int          // 0=精力充沛, 1=正常, 2=有点累, 3=很疲惫
    var skinCondition: String // good, normal, oily, acne, dry
    var temperature: String   // 体温
    var appetite: Int         // 0=正常, 1=增加, 2=减少
    var discharge: String     // none, clear, white, yellow, sticky

    init(
        id: UUID = UUID(),
        date: Date,
        mood: String = "",
        symptoms: String = "",
        notes: String = "",
        flowLevel: Int = 0,
        flowColor: String = "",
        painLevel: Int = 0,
        breastPain: Int = 0,
        digestive: Int = 0,
        backPain: Int = 0,
        headache: Int = 0,
        fatigue: Int = 0,
        skinCondition: String = "",
        temperature: String = "",
        appetite: Int = 0,
        discharge: String = ""
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.symptoms = symptoms
        self.notes = notes
        self.flowLevel = flowLevel
        self.flowColor = flowColor
        self.painLevel = painLevel
        self.breastPain = breastPain
        self.digestive = digestive
        self.backPain = backPain
        self.headache = headache
        self.fatigue = fatigue
        self.skinCondition = skinCondition
        self.temperature = temperature
        self.appetite = appetite
        self.discharge = discharge
    }
}
