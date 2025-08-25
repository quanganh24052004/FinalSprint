//
//  TagChip.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import SwiftUI
import RealmSwift

struct TagChip: View {
    let tag: String // tagId

    private var color: Color {
        let realm = try? RealmManager.makeRealm()
        if let t = realm?.object(ofType: TagRealm.self, forPrimaryKey: tag) {
            return Color(uiColor: UIColor(hex: t.colorHex))
        }
        return .gray
    }

    var body: some View {
        Circle().fill(color).frame(width: 10, height: 10)
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var c = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if c.count == 6 { c.append("FF") }
        var int: UInt64 = 0
        Scanner(string: c).scanHexInt64(&int)
        let a = CGFloat((int & 0xFF000000) >> 24) / 255
        let r = CGFloat((int & 0x00FF0000) >> 16) / 255
        let g = CGFloat((int & 0x0000FF00) >> 8) / 255
        let b = CGFloat(int & 0x000000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

//#Preview {
//    TagChip()
//}
