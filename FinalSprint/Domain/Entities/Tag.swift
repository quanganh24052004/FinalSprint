//
//  Tag.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import SwiftUI

enum BuiltInTag: String, CaseIterable, Identifiable {
    case congViec = "Công việc"
    case hocTap   = "Học tập"
    case thoiQuen = "Thói quen"
    case sucKhoe  = "Sức khoẻ"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .congViec: return .orange
        case .hocTap:   return .blue
        case .thoiQuen: return .green
        case .sucKhoe:  return .pink
        }
    }
}

struct Tag: Identifiable, Equatable {
    let id: String
    var name: String
    var colorHex: String
    var isBuiltIn: Bool
}
