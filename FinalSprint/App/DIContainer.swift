//
//  DIContainer.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import Foundation
final class DIContainer {
    static let shared = DIContainer()
    let repo: ReminderRepository = ReminderRepositoryRealm()
    private init() {}
}
