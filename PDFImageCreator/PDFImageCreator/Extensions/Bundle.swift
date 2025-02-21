//
//  Bundle.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation

extension Bundle {
    
    var appId: String {
        bundleIdentifier ?? "com.vsevolond.PDFEditorCreator"
    }
}
