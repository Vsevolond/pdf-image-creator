//
//  EditorViewModel.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation
import PhotosUI
import os

enum EditorInput {
    case gallery(results: [PHPickerResult])
    case documents(urls: [URL])
}

enum EditorState: Equatable {
    case idle
    case converting
    case converted(url: URL)
    case failed(error: EditorError)
}

enum EditorError: Error {
    case cannotLoadImage
    case noImageForResult
    case noDataForUrl
    case cannotSaveFile
    case noImages
}

final class EditorViewModel: ObservableObject {
    
    @Published var state: EditorState = .idle
    
    private let converter: PDFConverter
    
    private var convertTask: Task<Void, Error>?
    
    private lazy var logger = os.Logger(subsystem: Bundle.main.appId, category: "PDFEditorViewModel")
    
    init(converter: PDFConverter = PDFConverterImpl()) {
        self.converter = converter
    }
    
    func convert(input: EditorInput) {
        guard state == .idle else { return }
        state = .converting

        switch input {
        case .gallery(let results):
            convertTask = makeConvertTask(withLoader: { [weak self] in
                guard let self else { return [] }
                return try await loadImagesFromGallery(results)
            })
            
        case .documents(let urls):
            convertTask = makeConvertTask(withLoader: { [weak self] in
                guard let self else { return [] }
                return try await loadImagesFromDocuments(urls)
            })
        }
    }
    
    func cancel() {
        guard state != .idle else { return }
        
        convertTask?.cancel()
        convertTask = nil
    }
    
    private func makeConvertTask(
        withLoader imagesLoader: @escaping () async throws -> [UIImage]
    ) -> Task<Void, Error> {
        Task(priority: .userInitiated) {
            try await withTaskCancellationHandler {
                log("getting images")
                
                do {
                    let images = try await imagesLoader()
                    log("successfully got images")
                    
                    let data = converter.convert(images: images)
                    log("converted images to pdf data")
                    
                    let url = try await saveDataToTemp(data: data)
                    log("saved data to file")
                    
                    setState(.converted(url: url))
                    
                } catch let error as EditorError {
                    setState(.failed(error: error))
                }
                
            } onCancel: {
                log("cancelled converting")
            }

        }
    }
    
    private func setState(_ state: EditorState) {
        Task.delayed(byTimeInterval: 1) { @MainActor [weak self] in
            guard let self else { return }
            self.state = state
        }
    }
    
    private func loadImagesFromGallery(_ results: [PHPickerResult]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: (Int, UIImage?).self, returning: [UIImage].self) { [logger] group in
            for (index, result) in results.enumerated() {
                group.addTask {
                    do {
                        let image = try await result.itemProvider.loadImage()
                        return (index, image)
                        
                    } catch {
                        logger.error("📁 EditorViewModel: error in loading image: \(error)")
                        throw EditorError.cannotLoadImage
                    }
                }
            }
            
            var images: [UIImage?] = Array(repeating: nil, count: results.count)
            
            for try await (index, image) in group {
                guard let image else { throw EditorError.noImageForResult }
                images[index] = image
            }
            
            let result = images.compactMap { $0 }
            guard !result.isEmpty else { throw EditorError.noImages }
            
            return result
        }
    }
    
    private func loadImagesFromDocuments(_ urls: [URL]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: (Int, UIImage?).self, returning: [UIImage].self) { [logger] group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    do {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)
                        
                        return (index, image)
                        
                    } catch {
                        logger.error("📁 EditorViewModel: error in getting data: \(error)")
                        throw EditorError.noDataForUrl
                    }
                }
            }
            
            var images: [UIImage?] = Array(repeating: nil, count: urls.count)
            
            for try await (index, image) in group {
                guard let image else { throw EditorError.cannotLoadImage }
                images[index] = image
            }
            
            let result = images.compactMap { $0 }
            guard !result.isEmpty else { throw EditorError.noImages }
            
            return result
        }
    }
    
    private func saveDataToTemp(data: Data) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Untitled.pdf")
            
            do {
                try data.write(to: url)
                continuation.resume(returning: url)
                
            } catch {
                log("saving file error: \(error)")
                continuation.resume(throwing: EditorError.cannotSaveFile)
            }
        }
    }
    
    private func log(_ message: String) {
        logger.log("📁 PDFEditorViewModel: \(message)")
    }
}

private extension NSItemProvider {
    
    func loadImage() async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            loadObject(ofClass: UIImage.self) { item, error in
                if let error {
                    continuation.resume(throwing: error)
                    
                } else if let image = item as? UIImage {
                    continuation.resume(returning: image)
                    
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
