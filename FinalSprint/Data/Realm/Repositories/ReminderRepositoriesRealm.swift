//
//  ReminderRealm.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import Combine
import RealmSwift
import Realm

final class ReminderRepositoryRealm: ReminderRepository {
    private let realm: Realm
    private let subject = CurrentValueSubject<[Reminder], Never>([])

    private var token: NotificationToken?

    init() {
        self.realm = try! RealmManager.makeRealm()
        try? ensureBuiltInTags()
        observe()
    }

    deinit { token?.invalidate() }

    private func observe() {
        let results = realm.objects(ReminderRealm.self).sorted(byKeyPath: "createdAt", ascending: true)
        token = results.observe { [weak self] _ in
            self?.subject.send(results.map { $0.toDomain() })
        }
        subject.send(results.map { $0.toDomain() })
    }

    // MARK: - Publisher
    func allRemindersPublisher() -> AnyPublisher<[Reminder], Never> { subject.eraseToAnyPublisher() }

    // MARK: - CRUD
    func create(_ reminder: Reminder) throws {
        try realm.write {
            let obj = ReminderRealm.fromDomain(reminder, in: realm)
            realm.add(obj, update: .modified)
        }
    }

    func update(_ reminder: Reminder) throws {
        try realm.write {
            let obj = ReminderRealm.fromDomain(reminder, in: realm)
            obj.updatedAt = Date()
            realm.add(obj, update: .modified)
        }
    }

    func delete(id: String) throws {
        guard let obj = realm.object(ofType: ReminderRealm.self, forPrimaryKey: id) else { return }
        try realm.write { realm.delete(obj) }
    }

    func get(id: String) -> Reminder? {
        realm.object(ofType: ReminderRealm.self, forPrimaryKey: id)?.toDomain()
    }

    // MARK: - Tags
    func ensureBuiltInTags() throws {
        let names = Set(BuiltInTag.allCases.map(\.rawValue))
        let existing = Set(realm.objects(TagRealm.self).map(\.name))
        let missing = names.subtracting(existing)
        guard !missing.isEmpty else { return }

        try realm.write {
            for bi in BuiltInTag.allCases where missing.contains(bi.rawValue) {
                let t = TagRealm()
                t.name = bi.rawValue
                t.isBuiltIn = true
                realm.add(t, update: .modified)
            }
        }
    }
    func allTags() -> [Tag] {
        realm.objects(TagRealm.self).map { $0.toDomain() }
    }

    func createCustomTag(name: String, colorHex: String) throws -> Tag {
        let t = TagRealm()
        t.name = name
        t.isBuiltIn = false
        try realm.write { realm.add(t, update: .modified) }
        return t.toDomain()
    }
}

// MARK: - Mapping
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
                 isCompleted: isCompleted)
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
        obj.isCompleted = r.isCompleted
        return obj
    }
}

private extension TagRealm {
    func toDomain() -> Tag {
        Tag(id: id, name: name, isBuiltIn: isBuiltIn)
    }
}
