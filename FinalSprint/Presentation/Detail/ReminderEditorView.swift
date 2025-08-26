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
                Section {
                    TextField("Tiêu đề", text: $vm.title)
                    if let err = vm.titleError { Text(err).font(.footnote).foregroundStyle(.red) }

                    TextField("Mô tả", text: $vm.descriptionText, axis: .vertical)
                        .lineLimit(3...5)
                    if let err = vm.descError { Text(err).font(.footnote).foregroundStyle(.red) }
                }

                Section {
                    Toggle(isOn: $vm.useDate) {
                        HStack {
                            Image("ic_Date")
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text("Ngày")
                        }
                    }
                    if vm.useDate {
                        DatePicker("Ngày", selection: $vm.dueDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                        Toggle("Giờ", isOn: $vm.useTime)
                        if vm.useTime {
                            DatePicker("Time", selection: $vm.dueTime, displayedComponents: .hourAndMinute)
                        }
                    }
                    if let err = vm.dateError { Text(err).font(.footnote).foregroundStyle(.red) }
                }

                Section {
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
                    Button {
                        dismiss()
                    } label : {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            if await vm.save() { dismiss() }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
