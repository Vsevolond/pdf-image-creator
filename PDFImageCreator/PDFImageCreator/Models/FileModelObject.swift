//
//  FileModelObject.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation
import RealmSwift

final class FileModelObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var date: Date
}

extension FileModelObject {
    
    convenience init(from model: FileModel) {
        self.init()
        
        self.id = model.id
        self.name = model.name
        self.path = model.url.path
        self.date = model.date
    }
}
