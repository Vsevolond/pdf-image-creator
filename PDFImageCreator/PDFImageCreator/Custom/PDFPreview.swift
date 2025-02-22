//
//  PDFPreview.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI
import PDFKit

struct PDFPreview: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> some UIView {
        let view = PDFView()
        let document = PDFDocument(url: url)
        
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
