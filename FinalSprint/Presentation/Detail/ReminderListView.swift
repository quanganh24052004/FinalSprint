//
//  ReminderListView.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import SwiftUI

private struct EditingReminder: Identifiable, Equatable {
    let id: String
}

struct ReminderListView: View {
    @StateObject private var vm: ReminderListViewModel
    @State private var showingEditor = false
    @State private var editingId: EditingReminder? = nil
    @State private var justCreatedId: String? = nil
    private struct SheetItem: Identifiable { let id: String }

    init(repo: ReminderRepository) {
        _vm = StateObject(wrappedValue: ReminderListViewModel(repo: repo))
    }

    var body: some View {
        NavigationStack {
            List {
                content
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Reminders")
            .searchable(text: $vm.searchText, placement: .automatic, prompt: "Tìm theo tiêu đề…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sắp xếp", selection: $vm.sortKey) {
                            Text("Ngày tạo (cũ → mới)").tag(SortKey.createdAtAsc)
                            Text("Tiêu đề (A→Z)").tag(SortKey.titleAsc)
                            Text("Due date (gần → xa)").tag(SortKey.dueAsc)
                        }
                    } label: { Image(systemName: "arrow.up.arrow.down") }
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button {
                    // TẠO DRAFT VÀ FOCUS VÀO DÒNG MỚI
                    let newId = vm.createDraft()
                    justCreatedId = newId
                } label: {
                    Label("New Reminder", systemImage: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding()
            }
            .sheet(item: Binding(
                get: { editingId.map { SheetItem(id: $0.id) } },
                set: { editingId = $0.map { EditingReminder(id: $0.id) } }
            )) { item in
                ReminderEditorView(repo: DIContainer.shared.repo, editingId: item.id)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.today.isEmpty && vm.upcoming.isEmpty {
            emptyState
        } else {
            if !vm.today.isEmpty {
                todaySection
            }
            if !vm.upcoming.isEmpty {
                upcomingSection
            }
        }
    }

    private var emptyState: some View {
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Spacer()
                    Text("No reminder")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.neutral3)
                    Spacer()
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
    }

    private var todaySection: some View {
        Section("Today") {
            ForEach(vm.today) { r in
                ReminderRowView(
                    reminder: r,
                    onQuickEdit: { id, t, d in vm.quickUpdate(id: id, title: t, desc: d) },
                    onOpenDetail: { rem in editingId = EditingReminder(id: rem.id) },
                    isNewDraft: justCreatedId == r.id,
                    onAbandonDraft: { id in
                        vm.deleteDraft(id: id)
                        if justCreatedId == id { justCreatedId = nil }
                    }
                )
            }
            .onDelete { vm.delete(at: $0, isToday: true) }
        }
    }

    private var upcomingSection: some View {
        Section("Upcoming") {
            ForEach(vm.upcoming) { r in
                ReminderRowView(
                    reminder: r,
                    onQuickEdit: { id, t, d in vm.quickUpdate(id: id, title: t, desc: d) },
                    onOpenDetail: { rem in editingId = EditingReminder(id: rem.id) },
                    isNewDraft: justCreatedId == r.id,
                    onAbandonDraft: { id in
                        vm.deleteDraft(id: id)
                        if justCreatedId == id { justCreatedId = nil }
                    }
                )
            }
            .onDelete { vm.delete(at: $0, isToday: false) }
        }
    }
}
