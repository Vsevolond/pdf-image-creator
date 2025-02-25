//
//  StorageView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI
import PDFKit

private enum StorageSheetType: Equatable {
    case none
    case gallery
    case documents
    case share(url: URL)
}

struct StorageView: View {
    
    @StateObject private var model = StorageViewModel()
    
    @State private var sheetPresented = false
    @State private var sheetType: StorageSheetType = .none
    
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
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarMenu
                }
            }
        }
        .accentColor(.indigo)
        .sheet(
            isPresented: $sheetPresented,
            onDismiss: {
                sheetType = .none
            },
            content: {
                switch sheetType {
                case .none:
                    EmptyView()
                    
                case .gallery:
                    GalleryImagePicker(isPresented: $sheetPresented) { results in
                        openEditor(withInput: .gallery(results: results))
                    }
                    
                case .documents:
                    DocumentsImagePicker(isPresented: $sheetPresented) { results in
                        openEditor(withInput: .documents(urls: results))
                    }
                    
                case .share(let url):
                    ShareSheet(items: [url])
                }
            }
        )
        .onChange(of: sheetType) { type in
            guard type != .none else { return }
            sheetPresented.toggle()
        }
        .onAppear {
            model.fetch()
        }
    }
    
    private var FilesView: some View {
        List(model.files, id: \.id) { file in
            NavigationLink {
                PDFPreview(url: file.url)
                    .navigationTitle(file.name)
                    .navigationBarTitleDisplayMode(.inline)
                
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    AsyncThumbnailView(url: file.url)
                        .clipShape(.rect(cornerRadius: 5))
                        .frame(width: 60, height: 60)
                    
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
            .contextMenu {
                Button {
                    sheetType = .share(url: file.url)
                    
                } label: {
                    Label("Поделиться", systemImage: shareIcon)
                }

                Button(role: .destructive) {
                    
                } label: {
                    Label("Удалить", systemImage: deleteIcon)
                }

                Button {
                    
                } label: {
                    Label("Объединить", systemImage: unionIcon)
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
            
            Text(errorText)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    private var ToolbarMenu: some View {
        Menu {
            Button {
                sheetType = .gallery
                
            } label: {
                Label("Из галереи", systemImage: galleryIcon)
            }
            
            Button {
                sheetType = .documents
                
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
private let shareIcon = "square.and.arrow.up"
private let deleteIcon = "trash"
private let unionIcon = "square.2.layers.3d"

private let errorText = "Произошла ошибка при извлечении сохраненных файлов. Пожалуйста, попробуйте перезагрузить страницу."

#Preview {
    StorageView()
}
