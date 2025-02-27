//
//  StorageView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI

private enum FilesInterfaceType: String {
    case list
    case grid
    
    var title: String {
        switch self {
        case .list: "Список"
        case .grid: "Значки"
        }
    }
}

private enum StorageSheetType: Equatable {
    case none
    case gallery
    case documents
    case share(url: URL)
}

struct StorageView: View {
    @AppStorage(.filesInterface)
    private var filesInterface: FilesInterfaceType = .list
    
    @StateObject private var model = StorageViewModel()
    
    @State private var sheetPresented = false
    @State private var sheetType: StorageSheetType = .none
    
    @State private var editorPresented = false
    @State private var editorInput: EditorInput?
    
    @State private var alertPresented = false
    @State private var fileToDelete: FileModel?
    
    @Namespace private var namespace
    
    private var columns: [GridItem] {
        switch filesInterface {
        case .list: [listItem]
        case .grid: [gridItem, gridItem, gridItem]
        }
    }
    
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
                .tint(.primary)
            }
            .navigationTitle("Сохраненное")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ToolbarInterfaceButton
                }
                
                ToolbarItem(placement: .primaryAction) {
                    ToolbarAddButton
                }
            }
        }
        .tint(.indigo)
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
        .alert("", isPresented: $alertPresented,
            actions: {
                Button("Удалить", role: .destructive) {
                    guard let file = fileToDelete else { return }
                    
                    model.delete(file: file)
                    fileToDelete = nil
                }
                
                Button("Отменить", role: .cancel) {
                    alertPresented = false
                    fileToDelete = nil
                }
            },
            message: {
                Text("Точно хотите удалить файл?")
            }
        )
        .onChange(of: fileToDelete) { file in
            guard file != nil else { return }
            alertPresented.toggle()
        }
        .onAppear {
            model.fetch()
        }
    }
    
    @ViewBuilder
    private var FilesView: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(model.files, id: \.id) { file in
                    NavigationFileView(file: file)
                }
            }
            .animation(.snappy, value: filesInterface)
            .animation(.snappy, value: model.files)
        }
    }
    
    private func NavigationFileView(file: FileModel) -> some View {
        NavigationLink {
            PDFPreview(url: file.url)
                .navigationTitle(file.name)
                .navigationBarTitleDisplayMode(.inline)
            
        } label: {
            FileView(file: file, interface: $filesInterface, namespace: namespace)
        }
        .contextMenu {
            Button {
                sheetType = .share(url: file.url)
                
            } label: {
                Label("Поделиться", systemImage: shareIcon)
            }

            Button(role: .destructive) {
                fileToDelete = file
                
            } label: {
                Label("Удалить", systemImage: deleteIcon)
            }
        }
    }
    
    @ViewBuilder
    private var LoadingView: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(1...6, id: \.self) { _ in
                    Group {
                        switch filesInterface {
                        case .list:
                            VStack(alignment: .leading) {
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
                                
                                Divider()
                                    .padding(.leading, 60)
                                    .padding(.trailing, 20)
                            }
                            
                        case .grid:
                            VStack(alignment: .center) {
                                SkeletonRectangleView()
                                    .frame(width: 60, height: 60)
                                
                                SkeletonRectangleView()
                                    .frame(height: 25)
                                
                                SkeletonRectangleView()
                                    .frame(height: 20)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding([.horizontal, .top], 4)
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
    
    private var ToolbarAddButton: some View {
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
    
    private var ToolbarInterfaceButton: some View {
        Menu {
            Button {
                filesInterface = .list
                
            } label: {
                Label("Список", systemImage: filesInterface == .list ? markIcon : "")
            }

            Button {
                filesInterface = .grid
                
            } label: {
                Label("Значки", systemImage: filesInterface == .grid ? markIcon : "")
            }
            
        } label: {
            switch filesInterface {
            case .list:
                Image(systemName: listIcon)
                
            case .grid:
                Image(systemName: gridIcon)
            }
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

private struct FileView: View {
    private struct FileViewLayout: Equatable {
        let imageSize: CGFloat
        let nameFont: Font
        let nameAlignment: TextAlignment
        let dateFont: Font
        
        static let listLayout = FileViewLayout(imageSize: 60, nameFont: .system(size: 18, weight: .semibold), nameAlignment: .leading, dateFont: .system(size: 16))
        
        static let gridLayout = FileViewLayout(imageSize: 80, nameFont: .system(size: 16), nameAlignment: .center, dateFont: .system(size: 14))
    }
    
    let file: FileModel
    @Binding var interface: FilesInterfaceType
    let namespace: Namespace.ID
    
    private var layout: FileViewLayout {
        switch interface {
        case .list: FileViewLayout.listLayout
        case .grid: FileViewLayout.gridLayout
        }
    }
    
    var body: some View {
        Group {
            switch interface {
            case .list:
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 8) {
                        ThumbnailView
                        
                        VStack(alignment: .leading, spacing: 6) {
                            NameView
                            DateView
                        }
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                        .padding(.trailing, 20)
                }
                
            case .grid:
                VStack(alignment: .center) {
                    ThumbnailView
                    NameView
                    DateView
                }
            }
        }
        .padding([.horizontal, .top], 4)
    }
    
    private var ThumbnailView: some View {
        AsyncThumbnailView(url: file.url)
            .clipShape(.rect(cornerRadius: 5))
            .frame(width: layout.imageSize, height: layout.imageSize)
            .animation(.snappy, value: layout)
            .matchedGeometryEffect(
                id: "\(file.id)-image",
                in: namespace
            )
    }
    
    private var NameView: some View {
        Text(file.name)
            .font(layout.nameFont)
            .multilineTextAlignment(layout.nameAlignment)
            .animation(.snappy, value: layout)
    }
    
    private var DateView: some View {
        Text(file.dateString)
            .font(layout.dateFont)
            .foregroundStyle(.gray)
            .animation(.snappy, value: layout)
        
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

private let listIcon = "list.bullet"
private let gridIcon = "square.grid.3x3"
private let markIcon = "checkmark"

private let errorText = "Произошла ошибка при извлечении сохраненных файлов. Пожалуйста, попробуйте перезагрузить страницу."

private let gridItem = GridItem(.fixed(.screenWidth / 3), alignment: .top)
private let listItem = GridItem(.fixed(.screenWidth), alignment: .leading)

#Preview {
    StorageView()
}
