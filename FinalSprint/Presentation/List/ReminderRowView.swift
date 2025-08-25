//
//  ReminderRowView.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder

    var body: some View {
        HStack(spacing: 12) {
            TagChip(tag: reminder.tagId)
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title).font(.headline)
                if let d = reminder.description, !d.isEmpty {
                    Text(d).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer()
            Text(reminder.dueDate, style: .date)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Xoá sẽ được bắt ở List.onDelete (ở trên) – ở đây demo thêm:
            // Button(role: .destructive) { ... } label: { Label("Xoá", systemImage: "trash") }
        }
    }
}

//#Preview {
//    ReminderRowView()
//}
