//
//  Tag.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//


import SwiftUI
import Foundation

enum BuiltInTag: String, CaseIterable, Identifiable {
    case congViec = "Công việc"
    case hocTap   = "Học tập"
    case thoiQuen = "Thói quen"
    case sucKhoe  = "Sức khoẻ"

    var id: String { rawValue }

    /// Màu chữ sẽ lấy từ Asset Catalog (ví dụ: TagCôngViệc, TagHọcTập...)
    var color: Color {
        Color(rawValue)
    }
}

struct Tag: Identifiable, Equatable {
    let id: String
    var name: String
    var isBuiltIn: Bool
}

enum TagColorKey {
    static func fromName(_ name: String) -> String {
        switch name {
        case "Công việc": return "TagWork"
        case "Học tập":   return "TagStudy"
        case "Thói quen": return "TagHabit"
        case "Sức khoẻ":  return "TagHealth"
        default:          return "TagDefault" // tạo Color Set này (xám) làm fallback
        }
    }
}
