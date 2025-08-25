//
//  ImageStore.swift
//  FinalSprint
//
//  Created by EF2025 on 26/8/25.
//

import UIKit

enum ImageStore {
    static func save(_ image: UIImage, name: String = UUID().uuidString) throws -> String {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(name).jpg")
        guard let data = image.jpegData(compressionQuality: 0.85) else { throw NSError() }
        try data.write(to: url)
        return url.path
    }

    static func load(_ path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }
}
