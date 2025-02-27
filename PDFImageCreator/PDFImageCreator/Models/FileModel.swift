//
//  FileModel.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation

struct FileModel: Equatable {
    let id: UUID
    let name: String
    let url: URL
    let date: Date
    
    init(id: UUID = UUID(), name: String, url: URL, date: Date = Date.now) {
        self.id = id
        self.name = name
        self.url = url
        self.date = date
    }
}

extension FileModel {
    
    init(from object: FileModelObject) {
        self.id = object.id
        self.name = object.name
        self.url = URL(fileURLWithPath: object.path)
        self.date = object.date
    }
}
