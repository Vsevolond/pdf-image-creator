//
//  MainView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI

struct MainView: View {
    
    @State private var galleryPresented = false
    @State private var documentsPresented = false
    @State private var editorPresented = false
    
    @State private var editorInput: PDFEditorInput?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    
                }
                
                NavigationLink(destination: EditorView, isActive: $editorPresented) {
                    EmptyView()
                }
            }
            .navigationTitle("Сохраненное")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarMenu
            }
        }
        .sheet(isPresented: $galleryPresented) {
            GalleryImagePicker(isPresented: $galleryPresented) { results in
                openEditor(withInput: .gallery(results: results))
            }
        }
        .sheet(isPresented: $documentsPresented) {
            DocumentImagePicker(isPresented: $documentsPresented) { results in
                openEditor(withInput: .documents(urls: results))
            }
        }
    }
    
    private var ToolbarMenu: some View {
        Menu {
            Button {
                galleryPresented.toggle()
                
            } label: {
                Label("Из галереи", systemImage: galleryIcon)
            }
            
            Button {
                documentsPresented.toggle()
                
            } label: {
                Label("Из файлов", systemImage: documentsIcon)
            }

        } label: {
            Image(systemName: "plus")
                .foregroundStyle(.indigo)
        }
    }
    
    @ViewBuilder
    private var EditorView: some View {
        if let editorInput {
            let model = PDFEditorViewModel(input: editorInput)
            PDFEditorView(model: model)
            
        } else {
            EmptyView()
        }
    }
    
    private func openEditor(withInput input: PDFEditorInput) {
        editorInput = input
        editorPresented = true
    }
}

private let galleryIcon = "photo"
private let documentsIcon = "folder"

#Preview {
    MainView()
}
