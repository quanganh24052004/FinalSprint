//
//  ReminderDetailViewModel.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI

final class ReminderDetailViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var descriptionText: String = ""
    @Published var dueDate: Date = Date().dayOnly
    @Published var useTime: Bool = false
    @Published var dueTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    @Published var selectedTagId: String = ""
    @Published var photoPaths: [String] = []

    // PhotosPicker
    @Published var pickerItems: [PhotosPickerItem] = []

    // Validation states
    @Published private(set) var titleError: String?
    @Published private(set) var descError: String?
    @Published private(set) var dateError: String?

    private let repo: ReminderRepository
    private var editingId: String? // nil = create
    private var bag = Set<AnyCancellable>()

    let allTags: [Tag]

    init(repo: ReminderRepository, editingId: String? = nil) {
        self.repo = repo
        self.editingId = editingId
        self.allTags = repo.allTags()
        self.selectedTagId = allTags.first?.id ?? ""

        if let id = editingId, let r = repo.get(id: id) {
            self.title = r.title
            self.descriptionText = r.description ?? ""
            self.dueDate = r.dueDate.dayOnly
            self.selectedTagId = r.tagId
            self.photoPaths = r.photoPaths
            
            
        }

        // Load picked images → lưu local
        $pickerItems
            .dropFirst()
            .sink { items in
                Task { [weak self] in
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img = UIImage(data: data),
                           let path = try? ImageStore.save(img) {
                            await MainActor.run { self?.photoPaths.append(path) }
                        }
                    }
                }
            }
            .store(in: &bag)
    }

    // MARK: - Validation
    func validate() -> Bool {
        titleError = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || title.count > 50
        ? "Tiêu đề không trống (≤ 50 ký tự)"
        : nil

        descError = descriptionText.isEmpty ? nil : (descriptionText.count > 150 ? "Mô tả ≤ 150 ký tự" : nil)

        dateError = dueDate.isAfterOrEqualToday() ? nil : "Due Date phải ≥ hôm nay"

        return titleError == nil && descError == nil && dateError == nil
    }

    // MARK: - Save
    func save() async -> Bool {
        guard validate() else { return false }

        let now = Date()
        let base = Reminder(
            id: editingId ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: descriptionText.isEmpty ? nil : descriptionText,
            dueDate: dueDate.dayOnly,
            createdAt: editingId == nil ? now : (repo.get(id: editingId!)?.createdAt ?? now),
            updatedAt: now,
            tagId: selectedTagId,
            photoPaths: photoPaths
        )

        do {
            if editingId == nil {
                try repo.create(base)
            } else {
                try repo.update(base)
            }
            await NotificationScheduler.schedule1hBefore(reminderId: base.id, title: base.title, dueDateOnly: base.dueDate)
            return true
        } catch {
            return false
        }
    }
}
