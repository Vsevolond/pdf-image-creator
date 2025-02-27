//
//  EditorView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI

private enum EditorAlertType {
    case none
    case successfullySaved
    case fileWithSameNameExists
    case somethingWrong
    
    var title: String {
        switch self {
        case .none, .successfullySaved: ""
        case .fileWithSameNameExists, .somethingWrong: "Ошибка"
        }
    }
    
    var message: String {
        switch self {
        case .none: ""
        case .successfullySaved: "Файл успешно сохранен."
        case .fileWithSameNameExists: "Файл с таким именем уже существует."
        case .somethingWrong: "Произошла ошибка при сохранении файла. Пожалуйста, попробуйте еще раз или создайте другой файл."
        }
    }
}

struct EditorView: View {
    private let input: EditorInput
    
    @StateObject private var editorModel = EditorViewModel()
    @ObservedObject private var storageModel: StorageViewModel
    
    @State private var sharePresented = false
    
    @State private var alertPresented = false
    @State private var alertType: EditorAlertType = .none
    
    @State private var fileName = "Untitled"
    
    init(input: EditorInput, storageModel: StorageViewModel) {
        self.input = input
        self.storageModel = storageModel
    }
    
    var body: some View {
        Group {
            switch editorModel.state {
            case .idle, .converting:
                LoadingView
                
            case .converted(let url):
                PDFView(url: url)
                
            case .failed:
                ErrorView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertType.title, isPresented: $alertPresented) {
            Button("ОК") {
                alertPresented = false
                alertType = .none
            }
            
        } message: {
            Text(alertType.message)
        }
        .onAppear {
            editorModel.convert(input: input)
        }
        .onDisappear {
            editorModel.cancel()
        }
    }
    
    private func PDFView(url: URL) -> some View {
        PDFPreview(url: url)
            .ignoresSafeArea(edges: .bottom)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextField("Название файла", text: $fileName)
                        .multilineTextAlignment(.center)
                        .font(.headline.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarButton(url: url)
                }
            }
            .sheet(isPresented: $sharePresented) {
                ShareSheet(items: [url])
            }
    }
    
    private var LoadingView: some View {
        Spinner(lineWidth: 10, color: .indigo)
            .frame(width: 100, height: 100)
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
    
    private func ToolbarButton(url: URL) -> some View {
        Menu {
            Button {
                storageModel.tryToSaveFile(withName: fileName, from: url) {
                    alertType = .successfullySaved
                    alertPresented.toggle()
                    
                } onError: { error in
                    switch error {
                    case .fileExists:
                        alertType = .fileWithSameNameExists
                        
                    case .fileSavingFailed, .storageSavingFailed:
                        alertType = .somethingWrong
                    }
                    
                    alertPresented.toggle()
                }

            } label: {
                Label("Сохранить", systemImage: saveIcon)
            }
            
            Button {
                sharePresented.toggle()
                
            } label: {
                Label("Поделиться", systemImage: shareIcon)
            }
            
        } label: {
            Image(systemName: toolbarIcon)
        }

    }
}

private let errorIcon = "exclamationmark.triangle.fill"
private let toolbarIcon = "ellipsis.circle"
private let saveIcon = "tray.and.arrow.down"
private let shareIcon = "square.and.arrow.up"

private let errorText = "Произошла ошибка при конвертации изображений в PDF. Пожалуйста, убедитесь, что файлы поддерживаются и попробуйте снова."
