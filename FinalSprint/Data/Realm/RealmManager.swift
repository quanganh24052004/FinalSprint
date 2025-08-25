//
//  RealmManager.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import RealmSwift

enum RealmManager {
    static func makeRealm() throws -> Realm {
        var config = Realm.Configuration(schemaVersion: 2) // <-- bump lên 2
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                // v2 thêm field dueTimeMinutes (optional) => không cần thao tác
            }
        }
        Realm.Configuration.defaultConfiguration = config
        return try Realm()
    }
}
