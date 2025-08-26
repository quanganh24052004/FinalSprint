//
//  TagChip.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//
import SwiftUI
import RealmSwift

struct TagChip: View {
    let tag: String

    private var color: Color {
        guard
            let realm = try? RealmManager.makeRealm(),
            let t = realm.object(ofType: TagRealm.self, forPrimaryKey: tag)
        else {
            return Color("TagDefault")
        }
        return Color(TagColorKey.fromName(t.name))
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }
}
