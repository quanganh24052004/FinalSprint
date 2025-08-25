//
//  Reminder.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation

struct Reminder: Identifiable, Equatable {
    let id: String
    var title: String
    var description: String?
    var dueDate: Date
    var dueTimeMinutes: Int?
    var createdAt: Date
    var updatedAt: Date
    var tagId: String
    var photoPaths: [String]
}

extension Reminder {
    /// Kết hợp dueDate + dueTimeMinutes → Date đầy đủ
    var effectiveDueDate: Date {
        let base = dueDate.dayOnly
        guard let mins = dueTimeMinutes else {
            return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: base) ?? base
        }
        let h = mins / 60, m = mins % 60
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: base) ?? base
    }
}
