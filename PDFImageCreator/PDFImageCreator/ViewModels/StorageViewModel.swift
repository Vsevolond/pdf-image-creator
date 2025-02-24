//
//  StorageViewModel.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 22.02.2025.
//

import Foundation
import os

enum StorageError: Error {
    case fileExists
    case fileSavingFailed
    case storageSavingFailed
}

enum StorageState {
    case idle
    case loading
    case loaded
    case failed
}

final class StorageViewModel: ObservableObject {
    
    @Published var state: StorageState = .idle
    @Published var files = [FileModel]()
    
    private let helper: FileHelper
    private let storage: StorageService
    
    private lazy var logger = os.Logger(subsystem: Bundle.main.appId, category: "StorageViewModel")
    
    init(
        helper: FileHelper = FileHelperImpl(),
        storage: StorageService = StorageServiceImpl()
    ) {
        self.helper = helper
        self.storage = storage
    }
    
    func fetch() {
        guard state == .idle || state == .failed else { return }
        state = .loading
        
        Task.delayed(byTimeInterval: 1, priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            do {
                let objects = try await storage.fetch()
                let models = objects.map { FileModel(from: $0) }.sorted { $0.date > $1.date }
                
                Task { @MainActor in
                    self.files = models
                    self.state = .loaded
                }
                
            } catch is StorageServiceError {
                Task { @MainActor in
                    self.state = .failed
                }
            }
        }
    }
    
    func delete(id: UUID) {
        guard let (index, model) = files.enumerated().first(where: { $0.element.id == id }) else { return }
        
        files.remove(at: index)
        if let url = model.url { deleteFile(at: url) }
        
        Task(priority: .userInitiated) {
            do {
                try await storage.delete(id: id)
                
            } catch let error as StorageServiceError {
                switch error {
                case .savingFailed, .fetchingFailed:
                    assertionFailure("such error can't occur")
                    
                case .noObject, .deletingFailed:
                    log("file{id: \(id)} deleting failed")
                }
            }
        }
    }
}

extension StorageViewModel {
    
    func tryToSaveFile(
        withName name: String,
        from url: URL,
        onComplete: @escaping () -> Void,
        onError: @escaping (StorageError) -> Void
    ) {
        Task(priority: .userInitiated) {
            do {
                let newUrl = try await helper.tryToSaveFile(withName: name, from: url)
                let model = FileModel(name: name, url: newUrl)
                
                do {
                    let object = FileModelObject(from: model)
                    try await storage.save(object: object)
                    
                    Task { @MainActor in
                        files.insert(model, at: 0)
                        onComplete()
                    }
                    
                } catch is StorageServiceError {
                    deleteFile(at: newUrl)
                    
                    Task { @MainActor in
                        onError(.storageSavingFailed)
                    }
                }
                
            } catch let error as FileHelperError {
                switch error {
                case .fileExists:
                    Task { @MainActor in
                        onError(.fileExists)
                    }
                    
                case .noDirectoryUrl, .savingFailed:
                    Task { @MainActor in
                        onError(.fileSavingFailed)
                    }
                    
                case .deletingFailed:
                    assertionFailure("such error can't occur")
                }
            }
        }
    }
    
    private func deleteFile(at url: URL) {
        Task(priority: .userInitiated) {
            do {
                try await helper.deleteFile(at: url)
                
            } catch {
                log("file{url: \(url.lastPathComponent)} deleting failed")
            }
        }
    }
    
    private func log(_ message: String) {
        logger.log("⚙️ StorageViewModel: \(message)")
    }
}
