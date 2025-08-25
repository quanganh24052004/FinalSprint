//
//  ReminderEditorView.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import SwiftUI
import PhotosUI

struct ReminderEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: ReminderDetailViewModel

    init(repo: ReminderRepository, editingId: String? = nil) {
        _vm = StateObject(wrappedValue: ReminderDetailViewModel(repo: repo, editingId: editingId))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nội dung") {
                    TextField("Title *", text: $vm.title)
                    if let err = vm.titleError { Text(err).font(.footnote).foregroundStyle(.red) }

                    TextField("Description (≤ 150 ký tự)", text: $vm.descriptionText, axis: .vertical)
                        .lineLimit(3...5)
                    if let err = vm.descError { Text(err).font(.footnote).foregroundStyle(.red) }
                }

                Section("Thời hạn") {
                    DatePicker("Due Date", selection: $vm.dueDate, displayedComponents: .date)
                    Toggle("Đặt giờ cụ thể", isOn: $vm.useTime)
                    if vm.useTime {
                        DatePicker("Time", selection: $vm.dueTime, displayedComponents: .hourAndMinute)
                    }
                    if let err = vm.dateError { Text(err).font(.footnote).foregroundStyle(.red) }
                }

//                Section("Tag") {
//                    Picker("Chọn tag", selection: $vm.selectedTagId) {
//                        ForEach(vm.allTags) { t in
//                            HStack {
//                                Circle().fill(Color(uiColor: UIColor(hex: t.colorHex))).frame(width: 10, height: 10)
//                                Text(t.name)
//                            }
//                            .tag(t.id)
//                        }
//                    }
//                }

                Section("Ảnh đính kèm") {
                    PhotosPicker(selection: $vm.pickerItems, matching: .images, photoLibrary: .shared()) {
                        Label("Thêm ảnh", systemImage: "photo.on.rectangle")
                    }

                    if !vm.photoPaths.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(vm.photoPaths, id: \.self) { p in
                                    if let img = ImageStore.load(p) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminder")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Lưu") {
                        Task {
                            if await vm.save() { dismiss() }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

//#Preview {
//    ReminderEditorView()
//}
