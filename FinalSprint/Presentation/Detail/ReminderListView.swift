//
//  ReminderListView.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import SwiftUI

struct ReminderListView: View {
    @StateObject private var vm: ReminderListViewModel
    @State private var showingEditor = false

    init(repo: ReminderRepository) {
        _vm = StateObject(wrappedValue: ReminderListViewModel(repo: repo))
    }

    var body: some View {
        NavigationStack {
            List {
                if vm.today.isEmpty && vm.upcoming.isEmpty {
                    VStack(alignment: .center) {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Chưa có lời nhắc nào được thêm")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    if !vm.today.isEmpty {
                        Section("Today") {
                            ForEach(vm.today) { r in
                                ReminderRowView(reminder: r)
                            }
                            .onDelete { vm.delete(at: $0, isToday: true) }
                        }
                    }

                    if !vm.upcoming.isEmpty{
                        Section("Upcoming") {
                            ForEach(vm.upcoming) { r in
                                ReminderRowView(reminder: r)
                            }
                            .onDelete { vm.delete(at: $0, isToday: false) }
                        }
                    }
                }
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
                    showingEditor = true
                } label: {
                    Label("New Reminder", systemImage: "plus")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding()
            }
            .sheet(isPresented: $showingEditor) {
                ReminderEditorView(repo: DIContainer.shared.repo)
            }
        }
    }
}

//#Preview {
//    ReminderListView()
//}
