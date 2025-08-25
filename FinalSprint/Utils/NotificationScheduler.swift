//
//  NotificationScheduler.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import UserNotifications

enum NotificationScheduler {
    /// Lên lịch nhắc trước dueDate 1 giờ. Vì mình chỉ lưu "ngày",
    /// mặc định coi dueDate nổ lúc 09:00, thì notification lúc 08:00.
    static func schedule1hBefore(reminderId: String, title: String, dueDateTime: Date) async {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted == true else { return }

        let fire = dueDateTime.addingTimeInterval(-3600)
        guard fire > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Sắp đến hạn: \(title)"
        content.body = "Nhắc trước 1 giờ."
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder-\(reminderId)", content: content, trigger: trigger)
        try? await center.add(request)
    }

    static func cancel(reminderId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminder-\(reminderId)"])
    }
}
