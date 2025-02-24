//
//  EditorView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI

struct EditorView: View {
    private let input: EditorInput
    
    @StateObject private var editorModel = EditorViewModel()
    @ObservedObject private var storageModel: StorageViewModel
    
    @State private var sharePresented = false
    
    @State private var fileExistsPresented = false
    @State private var errorPresented = false
    @State private var successPresented = false
    
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
        .alert("", isPresented: $fileExistsPresented) {
            Button("ОК") {
                fileExistsPresented = false
            }
        } message: {
            Text("Файл с таким именем уже существует.")
        }
        .alert("Ошибка", isPresented: $errorPresented) {
            Button("ОК") {
                errorPresented = false
            }
        } message: {
            Text("Произошла ошибка при сохранении файла. Пожалуйста, попробуйте еще раз или создайте другой файл.")
        }
        .alert("", isPresented: $successPresented) {
            Button("ОК") {
                successPresented = false
            }
        } message: {
            Text("Файл успешно сохранен.")
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
            
            Text("Произошла ошибка при конвертации изображений в PDF. Пожалуйста, убедитесь, что файлы поддерживаются и попробуйте снова.")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
    
    private func ToolbarButton(url: URL) -> some View {
        Menu {
            Button {
                storageModel.tryToSaveFile(withName: fileName, from: url) {
                    successPresented.toggle()
                    
                } onError: { error in
                    switch error {
                    case .fileExists:
                        fileExistsPresented.toggle()
                        
                    case .fileSavingFailed, .storageSavingFailed:
                        errorPresented.toggle()
                    }
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
