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
        var config = Realm.Configuration(schemaVersion: 2)
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
            }
        }
        Realm.Configuration.defaultConfiguration = config
        return try Realm()
    }
}
