//
//  TagRealm.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import RealmSwift

final class TagRealm: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var colorHex: String = "#FF9500" // default orange
    @Persisted var isBuiltIn: Bool = true
}
