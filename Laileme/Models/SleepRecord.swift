import Foundation
import SwiftData

@Model
final class SleepRecord {
    @Attribute(.unique) var dateString: String  // "yyyy-MM-dd"
    var bedtime: String   // "HH:mm"
    var waketime: String  // "HH:mm"

    init(dateString: String, bedtime: String = "", waketime: String = "") {
        self.dateString = dateString
        self.bedtime = bedtime
        self.waketime = waketime
    }
}
