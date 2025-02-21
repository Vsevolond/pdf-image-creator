//
//  PDFPreview.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI
import PDFKit

enum PDFRepresentation {
    case data(_ data: Data)
    case url(_ url: URL)
}

struct PDFPreview: UIViewRepresentable {
    
    let representation: PDFRepresentation
    
    func makeUIView(context: Context) -> some UIView {
        let view = PDFView()
        
        let document = {
            switch representation {
            case .data(let data): PDFDocument(data: data)
            case .url(let url): PDFDocument(url: url)
            }
        }()
        
        view.document = document
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
