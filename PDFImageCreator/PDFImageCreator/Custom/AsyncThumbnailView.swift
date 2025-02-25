//
//  AsyncThumbnailView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 22.02.2025.
//

import SwiftUI
import PDFKit

struct AsyncThumbnailView: View {
    
    let url: URL
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        if let thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        } else {
            SkeletonRectangleView()
                .task(priority: .high) {
                    await loadThumbnail()
                }
        }
    }
    
    private func loadThumbnail() async {
        guard
            let document = PDFDocument(url: url),
            let page = document.page(at: 0)
        else {
            print("❌ Ошибка загрузки PDF: \(url)")
            return
        }
        
        let rect = page.bounds(for: .mediaBox)
        let image = page.thumbnail(of: rect.size, for: .mediaBox)
        
        await MainActor.run {
            self.thumbnail = image
        }
    }
}
