//
//  ReminderRowView.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

//import SwiftUI

//struct ReminderRowView: View {
//    let reminder: Reminder
//
//    var body: some View {
//        HStack(spacing: 12) {
//            TagChip(tag: reminder.tagId)
//            VStack(alignment: .leading, spacing: 4) {
//                Text(reminder.title)
//                    .font(.system(size: 17))
//                    .foregroundColor(.neutral1)
//                if let d = reminder.description, !d.isEmpty {
//                    Text(d)
//                        .font(.system(size: 15))
//                        .foregroundStyle(.neutral2)
//                        .lineLimit(1)
//                }
//            }
//            Spacer()
//            Button(action: {
//            }, label: {
//                Image(systemName: "info.circle")
//                    .font(.system(size: 20, weight: .semibold))
//            })
//        }
//        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//            // Xoá sẽ được bắt ở List.onDelete (ở trên) – ở đây demo thêm:
//            // Button(role: .destructive) { ... } label: { Label("Xoá", systemImage: "trash") }
//        }
//    }
//}
import SwiftUI

struct ReminderRowView: View {
    // MARK: Input
    let reminder: Reminder
    /// Gọi khi user chỉnh nhanh (inline) → lưu Realm
    let onQuickEdit: (_ id: String, _ newTitle: String, _ newDesc: String?) -> Void
    /// Gọi khi bấm info → mở editor chi tiết
    let onOpenDetail: (_ r: Reminder) -> Void

    // MARK: Local states (đồng bộ với reminder)
    @State private var title: String
    @State private var desc: String
    @FocusState private var focused: Field?
    @State private var saveTask: Task<Void, Never>? // debounce

    private enum Field { case title, desc }

    init(
        reminder: Reminder,
        onQuickEdit: @escaping (_ id: String, _ newTitle: String, _ newDesc: String?) -> Void,
        onOpenDetail: @escaping (_ r: Reminder) -> Void
    ) {
        self.reminder = reminder
        self.onQuickEdit = onQuickEdit
        self.onOpenDetail = onOpenDetail
        _title = State(initialValue: reminder.title)
        _desc  = State(initialValue: reminder.description ?? "")
    }

    var body: some View {
        HStack(spacing: 12) {
            TagChip(tag: reminder.tagId)

            VStack(alignment: .leading, spacing: 4) {
                // Title editable
                TextField("Title * (≤ 50)", text: $title)
                    .font(.system(size: 17))
                    .foregroundColor(.neutral1)
                    .focused($focused, equals: .title)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
                    .submitLabel(.done)
                    .onSubmit { commitSave() }
                    .onChange(of: title) { _ in scheduleDebouncedSave() }

                // Description editable (optional)
                TextField("Description (≤ 150)", text: $desc)
                    .font(.system(size: 15))
                    .foregroundStyle(.neutral2)
                    .lineLimit(1)
                    .focused($focused, equals: .desc)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
                    .submitLabel(.done)
                    .onSubmit { commitSave() }
                    .onChange(of: desc) { _ in scheduleDebouncedSave() }
            }

            Spacer()

            Button {
                onOpenDetail(reminder)
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 20, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle()) // dễ tap vào textfield
        .onDisappear { commitSave() } // rời cell vẫn đảm bảo lưu
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Xoá dùng List.onDelete ở ListView (giữ nguyên)
        }
    }

    // MARK: Save helpers
    private func scheduleDebouncedSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000) // ~400ms
            commitSave()
        }
    }

    private func commitSave() {
        // Validate inline (theo rule đã thống nhất)
        let newTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var newDesc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
        if newDesc.isEmpty { newDesc = "" }

        guard !newTitle.isEmpty, newTitle.count <= 50, newDesc.count <= 150 else {
            // Nếu không hợp lệ → rollback nhẹ về giá trị cũ
            title = reminder.title
            desc = reminder.description ?? ""
            return
        }

        // Chỉ gọi lưu nếu có thay đổi thật
        if newTitle != reminder.title || newDesc != (reminder.description ?? "") {
            onQuickEdit(reminder.id, newTitle, newDesc.isEmpty ? nil : newDesc)
        }
    }
}
//#Preview {
//    ReminderRowView(reminder: Reminder(
//        id: "test-id-1",
//        title: "Sample Reminder",
//        description: "This is a sample description to preview the row.",
//        dueDate: .now,
//        dueTimeMinutes: nil,
//        createdAt: .now.addingTimeInterval(-3600),
//        updatedAt: .now,
//        tagId: "home",
//        photoPaths: []
//    ))
//}
