import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - 请求权限
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("[Notification] 权限已获取")
            }
        }
    }

    // MARK: - 经期提醒
    func schedulePeriodReminder(daysUntil: Int) {
        cancelPeriodReminder()
        guard daysUntil > 0 && daysUntil <= 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "经期提醒 🌸"
        content.body = periodReminderMessage(daysUntil: daysUntil)
        content.sound = .default

        // 每天早上9点提醒
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "period_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelPeriodReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["period_reminder"])
    }

    // MARK: - 伴侣数据更新通知
    func sendPartnerUpdateNotification(fromNickname: String) {
        let content = UNMutableNotificationContent()
        content.title = "伴侣数据更新 💕"
        content.body = "\(fromNickname)更新了经期数据，快去看看吧~"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "partner_update_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 关怀消息
    private let periodMessages = [
        "宝贝，经期快到了，记得准备好姨妈巾哦~ 💝",
        "亲爱的，注意保暖，多喝热水，少吃生冷食物 🌸",
        "经期将至，这几天好好照顾自己，你值得被温柔以待 🥰",
        "宝贝记得备好暖宝宝，不要太累了 💕",
        "快来姨妈了，提前准备好吧，爱你~ ❤️"
    ]

    private let duringPeriodMessages = [
        "经期中要好好休息，不要太劳累哦~ 💗",
        "多喝温水，注意保暖，抱抱你 🤗",
        "姨妈期间少碰冷的，好好爱自己 🌷",
        "今天辛苦了，好好休息吧 💤",
        "你是最棒的，经期也要开开心心的 🌈"
    ]

    private func periodReminderMessage(daysUntil: Int) -> String {
        switch daysUntil {
        case 1: return "明天姨妈就要来啦，提前做好准备吧~ 🌸"
        case 2: return "还有2天姨妈就到了，记得准备姨妈巾哦~ 💝"
        case 3: return "距离下次经期还有3天，提前注意饮食和休息~ 💕"
        default: return periodMessages.randomElement() ?? periodMessages[0]
        }
    }

    func getCareMessage(isInPeriod: Bool, daysUntil: Int) -> String {
        if isInPeriod {
            return duringPeriodMessages.randomElement() ?? duringPeriodMessages[0]
        } else if daysUntil <= 3 {
            return periodReminderMessage(daysUntil: daysUntil)
        }
        return ""
    }
}
