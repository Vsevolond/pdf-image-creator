//
//  PDFEditorView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI

struct PDFEditorView: View {
    
    @ObservedObject var model: PDFEditorViewModel
    
    var body: some View {
        ZStack {
            switch model.state {
            case .idle, .converting:
                LoadingView
                
            case .converted(let data):
                PDFPreview(representation: .data(data))
                
            case .failed:
                ErrorView
            }
        }
        .onAppear {
            model.convert()
        }
        .onDisappear {
            model.cancel()
        }
    }
    
    private var LoadingView: some View {
        Spinner(count: 8, size: 20, color: .indigo)
            .frame(width: 100, height: 100)
    }
    
    private var ErrorView: some View {
        VStack {
            Image(systemName: errorIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.red)
                .frame(width: 40)
            
            Text("Произошла ошибка при конвертации изображений в PDF. Пожалуйста, убедитесь, что файлы поддерживаются и попробуйте снова.")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

private let errorIcon = "exclamationmark.triangle.fill"

#Preview {
    let model = PDFEditorViewModel(input: .gallery(results: []))
    PDFEditorView(model: model)
}
