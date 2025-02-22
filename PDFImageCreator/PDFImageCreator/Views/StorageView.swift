//
//  StorageView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI

struct StorageView: View {
    
    @StateObject private var model = StorageViewModel()
    
    @State private var galleryPresented = false
    @State private var documentsPresented = false
    @State private var editorPresented = false
    
    @State private var editorInput: EditorInput?
    
    var body: some View {
        NavigationView {
            VStack {
                List(model.files, id: \.id) { file in
                    Text(file.name)
                }
                .listStyle(.plain)
                
                NavigationLink(destination: EditView, isActive: $editorPresented) {
                    EmptyView()
                }
            }
            .navigationTitle("Сохраненное")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarMenu
            }
        }
        .accentColor(.indigo)
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
        .onAppear {
            model.fetch()
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
        }
    }
    
    @ViewBuilder
    private var EditView: some View {
        if let editorInput {
            EditorView(input: editorInput, storageModel: model)
            
        } else {
            EmptyView()
        }
    }
    
    private func openEditor(withInput input: EditorInput) {
        editorInput = input
        editorPresented = true
    }
}

private let galleryIcon = "photo"
private let documentsIcon = "folder"

#Preview {
    StorageView()
}
