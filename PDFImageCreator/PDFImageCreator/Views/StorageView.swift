//
//  StorageView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI
import PDFKit

struct StorageView: View {
    
    @StateObject private var model = StorageViewModel()
    
    @State private var galleryPresented = false
    @State private var documentsPresented = false
    @State private var editorPresented = false
    
    @State private var editorInput: EditorInput?
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: EditView, isActive: $editorPresented) {
                    EmptyView()
                }
                
                Group {
                    switch model.state {
                    case .idle, .loading:
                        LoadingView
                        
                    case .loaded:
                        FilesView
                        
                    case .failed:
                        ErrorView
                    }
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
    
    private var FilesView: some View {
        List(model.files, id: \.id) { file in
            HStack(alignment: .center, spacing: 8) {
                if let url = file.url {
                    AsyncThumbnailView(url: url)
                        .clipShape(.rect(cornerRadius: 5))
                        .frame(width: 60, height: 60)
                    
                } else {
                    Image(systemName: documentIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(file.name)
                        .font(.system(size: 18))
                        .bold()
                    
                    Text(file.dateString)
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var LoadingView: some View {
        List {
            ForEach(0...5, id: \.self) { _ in
                HStack(alignment: .center, spacing: 8) {
                    SkeletonRectangleView()
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonRectangleView()
                            .frame(width: 200, height: 25)
                        
                        SkeletonRectangleView()
                            .frame(width: 150, height: 20)
                    }
                }
            }
        }
    }
    
    private var ErrorView: some View {
        VStack {
            Image(systemName: errorIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.red)
                .frame(width: 40)
            
            Text("Произошла ошибка при извлечении сохраненных файлов. Пожалуйста, перезагрузите приложение.")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
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

private extension FileModel {
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YY"
        return formatter.string(from: date)
    }
}

private let galleryIcon = "photo"
private let documentsIcon = "folder"
private let errorIcon = "exclamationmark.triangle.fill"
private let documentIcon = "text.document.fill"

#Preview {
    StorageView()
}
