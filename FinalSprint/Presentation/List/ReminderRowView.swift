//
//  ReminderRowView.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import SwiftUI
import RealmSwift

struct ReminderRowView: View {
    let reminder: Reminder
    let onQuickEdit: (_ id: String, _ newTitle: String, _ newDesc: String?) -> Void
    let onOpenDetail: (_ r: Reminder) -> Void

    // NEW:
    let isNewDraft: Bool
    let onAbandonDraft: (_ id: String) -> Void

    @State private var title: String
    @State private var desc: String
    @FocusState private var focused: Field?
    @State private var saveTask: Task<Void, Never>?
    private enum Field { case title, desc }

    // Lấy tên tag display name dựa trên tagId
    private var tagDisplayName: String {
        guard
            let realm = try? RealmManager.makeRealm(),
            let t = realm.object(ofType: TagRealm.self, forPrimaryKey: reminder.tagId)
        else {
            return ""
        }
        return t.name
    }

    init(
        reminder: Reminder,
        onQuickEdit: @escaping (_ id: String, _ newTitle: String, _ newDesc: String?) -> Void,
        onOpenDetail: @escaping (_ r: Reminder) -> Void,
        isNewDraft: Bool = false,
        onAbandonDraft: @escaping (_ id: String) -> Void = { _ in }
    ) {
        self.reminder = reminder
        self.onQuickEdit = onQuickEdit
        self.onOpenDetail = onOpenDetail
        self.isNewDraft = isNewDraft
        self.onAbandonDraft = onAbandonDraft
        _title = State(initialValue: reminder.title)
        _desc  = State(initialValue: reminder.description ?? "")
    }

    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 4) {
                    TextField("Title", text: $title)
                        .font(.system(size: 17))
                        .foregroundColor(.neutral1)
                        .focused($focused, equals: .title)
                        .submitLabel(.done)
                        .onSubmit { commitSave() }
                        .onChange(of: focused) { _, newFocus in
                            // Nếu vừa mất focus khỏi Title, lại là draft + title trống => huỷ ngay
                            if (newFocus == nil), isNewDraft, title.trimmingCharacters(in: .whitespaces).isEmpty {
                                onAbandonDraft(reminder.id)
                            }
                        }


                TextField("Description (≤ 150)", text: $desc)
                    .font(.system(size: 15))
                    .foregroundStyle(.neutral2)
                    .lineLimit(1)
                    .focused($focused, equals: .desc)
                    .submitLabel(.done)
                    .onSubmit { commitSave() }
                    .onChange(of: desc) { scheduleDebouncedSave() }
            }

            Spacer()

            TagChip(tag: reminder.tagId)
                .padding(16)
            Button { onOpenDetail(reminder) } label: {
                Image(systemName: "info.circle").font(.system(size: 20, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onAppear {
            // focus title nếu là draft vừa tạo
            if isNewDraft {
                DispatchQueue.main.async { focused = .title }
            }
        }
        .onDisappear {
            // nếu là draft và title rỗng → huỷ
            if isNewDraft && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                onAbandonDraft(reminder.id)
            } else {
                commitSave()
            }
        }
    }

    private func scheduleDebouncedSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            commitSave()
        }
    }

    private func commitSave() {
        let newTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var newDesc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
        if newDesc.isEmpty { newDesc = "" }

        // Nếu là draft và title vẫn rỗng → chưa lưu (đợi user tiếp tục hoặc sẽ xoá khi thoát)
        if isNewDraft && newTitle.isEmpty { return }

        // Validate inline
        guard !newTitle.isEmpty, newTitle.count <= 50, newDesc.count <= 150 else {
            // rollback về giá trị đã lưu
            title = reminder.title
            desc  = reminder.description ?? ""
            return
        }

        if newTitle != reminder.title || newDesc != (reminder.description ?? "") {
            onQuickEdit(reminder.id, newTitle, newDesc.isEmpty ? nil : newDesc)
        }
    }
}

