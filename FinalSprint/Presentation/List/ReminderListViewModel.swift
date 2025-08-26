//
//  ReminderListViewModel.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
import Combine

final class ReminderListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sortKey: SortKey = .createdAtAsc

    @Published private(set) var today: [Reminder] = []
    @Published private(set) var upcoming: [Reminder] = []

    private let repo: ReminderRepository
    private var bag = Set<AnyCancellable>()

    init(repo: ReminderRepository) {
        self.repo = repo

        let all = repo.allRemindersPublisher()

        Publishers.CombineLatest(
            all,
            $searchText
                .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
                .removeDuplicates()
        )
        .map { [weak self] reminders, query in
            let filtered = query.isEmpty
            ? reminders
            : reminders.filter { $0.title.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil }

            let sorted: [Reminder]
            switch self?.sortKey ?? .createdAtAsc {
            case .createdAtAsc: sorted = filtered.sorted { $0.createdAt < $1.createdAt }
            case .titleAsc:     sorted = filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            case .dueAsc:       sorted = filtered.sorted { $0.dueDate < $1.dueDate }
            }

            return sorted
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] items in
            guard let self else { return }
            let t = items.filter { $0.dueDate.isToday }
            let u = items.filter { !$0.dueDate.isToday && $0.dueDate.isAfterOrEqualToday() }
            self.today = t
            self.upcoming = u
        }
        .store(in: &bag)

        // Khi sortKey thay đổi → re-emit bằng cách "kích" searchText
        $sortKey
            .sink { [weak self] _ in self?.searchText = self?.searchText ?? "" }
            .store(in: &bag)
    }

    func delete(at offsets: IndexSet, isToday: Bool) {
        let source = isToday ? today : upcoming
        for index in offsets {
            try? repo.delete(id: source[index].id)
            NotificationScheduler.cancel(reminderId: source[index].id)
        }
    }
    
    func quickUpdate(id: String, title: String, desc: String?) {
        // Lấy bản gốc để giữ nguyên các trường khác
        guard var r = repo.get(id: id) else { return }
        r.title = title
        r.description = desc
        r.updatedAt = Date()
        try? repo.update(r)
    }
    
    func createDraft() -> String {
        let id = UUID().uuidString
        let now = Date()
        // chọn tag mặc định
        let defaultTagId = repo.allTags().first?.id ?? ""

        let r = Reminder(
            id: id,
            title: "",                     // trống -> Row sẽ focus để người dùng nhập
            description: nil,
            dueDate: Date().dayOnly,       // mặc định hôm nay
            dueTimeMinutes: nil,           // chưa chọn giờ
            createdAt: now,
            updatedAt: now,
            tagId: defaultTagId,
            photoPaths: []
        )
        try? repo.create(r)
        return id
    }

    func deleteDraft(id: String) {
        try? repo.delete(id: id)
    }

}


