//
//  Date+Only.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation

extension Date {
    var dayOnly: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool { Calendar.current.isDateInToday(self) }
    func isAfterOrEqualToday() -> Bool {
        let today = Date().dayOnly
        return self.dayOnly >= today
    }
}
