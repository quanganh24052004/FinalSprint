//
//  ReminderRealm.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import Combine

enum SortKey {
    case createdAtAsc
    case titleAsc
    case dueAsc
}

protocol ReminderRepository {
    // Stream tất cả reminders (đã filter theo search & sort ở ViewModel)
    func allRemindersPublisher() -> AnyPublisher<[Reminder], Never>

    // CRUD
    func create(_ reminder: Reminder) throws
    func update(_ reminder: Reminder) throws
    func delete(id: String) throws
    func get(id: String) -> Reminder?

    // Tags
    func ensureBuiltInTags() throws
    func allTags() -> [Tag]
    func createCustomTag(name: String, colorHex: String) throws -> Tag
}
