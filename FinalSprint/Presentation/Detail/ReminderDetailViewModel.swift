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
    @Published var useDate: Bool = false
    @Published var dueDate: Date = Date().dayOnly
    @Published var useTime: Bool = false
    @Published var dueTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    @Published var selectedTagId: String = ""
    @Published var photoPaths: [String] = []

    @Published var pickerItems: [PhotosPickerItem] = []

    @Published private(set) var titleError: String?
    @Published private(set) var descError: String?
    @Published private(set) var dateError: String?

    private let repo: ReminderRepository
    private var editingId: String?
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
            
            self.useDate = true
            if let mins = r.dueTimeMinutes {
                self.useTime = true
                let h = mins / 60, m = mins % 60
                self.dueTime = Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: r.dueDate) ?? r.dueDate
            } else {
                self.useTime = false
            }
        }

        $useDate
            .sink { [weak self] enabled in
                if !enabled {
                    self?.useTime = false
                }
            }
            .store(in: &bag)

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
        ? "Tiêu đề không trống (≤ 50 ký tự)" : nil

        descError = descriptionText.isEmpty ? nil : (descriptionText.count > 150 ? "Mô tả ≤ 150 ký tự" : nil)

        // Ngày+giờ hiệu lực
        if !useDate {
            dateError = nil // Không kiểm tra ngày nếu không dùng ngày
        } else {
            let effDue: Date = {
                if useTime {
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: dueTime)
                    let h = comps.hour ?? 9, m = comps.minute ?? 0
                    return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: dueDate.dayOnly) ?? dueDate.dayOnly
                } else {
                    return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: dueDate.dayOnly) ?? dueDate.dayOnly
                }
            }()
            dateError = effDue >= Date() ? nil : "Due Date/Time phải ≥ hiện tại"
        }
        return titleError == nil && descError == nil && dateError == nil
    }

    func save() async -> Bool {
        guard validate() else { return false }

        let now = Date()
        let mins: Int? = {
            guard useTime && useDate else { return nil }
            let comps = Calendar.current.dateComponents([.hour, .minute], from: dueTime)
            return (comps.hour ?? 9) * 60 + (comps.minute ?? 0)
        }()

        let base = Reminder(
            id: editingId ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: descriptionText.isEmpty ? nil : descriptionText,
            dueDate: useDate ? dueDate.dayOnly : Date.distantFuture, // Nếu không dùng ngày thì lưu distantFuture
            dueTimeMinutes: useTime && useDate ? mins : nil,
            createdAt: editingId == nil ? now : (repo.get(id: editingId!)?.createdAt ?? now),
            updatedAt: now,
            tagId: selectedTagId,
            photoPaths: photoPaths,
            isCompleted: false
        )

        do {
            if editingId == nil { try repo.create(base) } else { try repo.update(base) }
            if useDate {
                await NotificationScheduler.schedule1hBefore(reminderId: base.id,
                                                             title: base.title,
                                                             dueDateTime: base.effectiveDueDate)
            }
            return true
        } catch {
            return false
        }
    }
}

