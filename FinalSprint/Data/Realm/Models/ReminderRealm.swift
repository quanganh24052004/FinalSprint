//
//  TagRealm.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import RealmSwift

final class ReminderRealm: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var descText: String?
    @Persisted var dueDate: Date = Date()
    @Persisted var dueTimeMinutes: Int?    // <-- mới
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var tag: TagRealm?
    @Persisted var photoPaths: List<String>
    @Persisted var isCompleted: Bool = false
}

// Mapping
private extension ReminderRealm {
    func toDomain() -> Reminder {
        Reminder(id: id,
                 title: title,
                 description: descText,
                 dueDate: dueDate,
                 dueTimeMinutes: dueTimeMinutes,
                 createdAt: createdAt,
                 updatedAt: updatedAt,
                 tagId: tag?.id ?? "",
                 photoPaths: Array(photoPaths),
                 isCompleted: false)
    }

    static func fromDomain(_ r: Reminder, in realm: Realm) -> ReminderRealm {
        let obj = ReminderRealm()
        obj.id = r.id
        obj.title = r.title
        obj.descText = r.description
        obj.dueDate = r.dueDate
        obj.dueTimeMinutes = r.dueTimeMinutes
        obj.createdAt = r.createdAt
        obj.updatedAt = r.updatedAt
        obj.tag = realm.object(ofType: TagRealm.self, forPrimaryKey: r.tagId)
        obj.photoPaths.removeAll()
        obj.photoPaths.append(objectsIn: r.photoPaths)
        return obj
    }
}
