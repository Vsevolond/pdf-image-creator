//
//  PDFEditorViewModel.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation
import PhotosUI
import os

enum PDFEditorInput {
    case gallery(results: [PHPickerResult])
    case documents(urls: [URL])
}

enum PDFEditorState {
    case idle
    case converting
    case converted(data: Data)
    case failed(error: PDFEditorError)
}

enum PDFEditorError: Error {
    case cannotLoadImage
    case noImageForResult
    case noDataForUrl
}

final class PDFEditorViewModel: ObservableObject {
    
    @Published var state: PDFEditorState = .idle
    
    private let input: PDFEditorInput
    private let converter: PDFConverter
    
    private var convertTask: Task<Void, Never>?
    
    private lazy var logger = os.Logger(subsystem: Bundle.main.appId, category: "PDFEditorViewModel")
    
    init(input: PDFEditorInput, converter: PDFConverter = PDFConverterImpl()) {
        self.input = input
        self.converter = converter
    }
    
    func convert() {
        state = .converting

        switch input {
        case .gallery(let results):
            convertTask = Task(priority: .userInitiated) {
                await withTaskCancellationHandler {
                    log("getting images from results")
                    
                    do {
                        let images = try await loadImagesFromGallery(results)
                        log("successfully got images from results")
                        
                        let data = converter.convert(images: images)
                        log("converted images to pdf data")
                        
                        setState(.converted(data: data))
                        
                    } catch let error as PDFEditorError {
                        setState(.failed(error: error))
                        
                    } catch {
                        assertionFailure("unknown error: \(error)")
                    }
                    
                } onCancel: {
                    log("cancelled converting")
                }
            }
            
        case .documents(let urls):
            convertTask = Task(priority: .userInitiated) {
                await withTaskCancellationHandler {
                    log("getting images by urls")
                    
                    do {
                        let images = try await loadImagesFromDocuments(urls)
                        log("successfully got images by urls")
                        
                        let data = converter.convert(images: images)
                        log("converted images to pdf data")
                        
                        setState(.converted(data: data))
                        
                    } catch let error as PDFEditorError {
                        setState(.failed(error: error))
                        
                    } catch {
                        assertionFailure("unknown error: \(error)")
                    }
                    
                } onCancel: {
                    log("cancelled converting")
                }
            }
        }
    }
    
    func cancel() {
        convertTask?.cancel()
        convertTask = nil
    }
    
    private func setState(_ state: PDFEditorState) {
        Task.delayed(byTimeInterval: 1) { @MainActor [weak self] in
            guard let self else { return }
            self.state = state
        }
    }
    
    private func loadImagesFromGallery(_ results: [PHPickerResult]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage?.self, returning: [UIImage].self) { [logger] group in
            for result in results {
                group.addTask {
                    do {
                        return try await result.itemProvider.loadImage()
                        
                    } catch {
                        logger.error("📁 PDFEditorViewModel: error in loading image: \(error)")
                        throw PDFEditorError.cannotLoadImage
                    }
                }
            }
            
            var images = [UIImage]()
            for try await image in group {
                guard let image else { throw PDFEditorError.noImageForResult }
                images.append(image)
            }
            
            return images
        }
    }
    
    private func loadImagesFromDocuments(_ urls: [URL]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage?.self, returning: [UIImage].self) { [logger] group in
            for url in urls {
                group.addTask {
                    do {
                        let data = try Data(contentsOf: url)
                        return UIImage(data: data)
                        
                    } catch {
                        logger.error("📁 PDFEditorViewModel: error in getting data: \(error)")
                        throw PDFEditorError.noDataForUrl
                    }
                }
            }
            
            var images = [UIImage]()
            for try await image in group {
                guard let image else { throw PDFEditorError.cannotLoadImage }
                images.append(image)
            }
            
            return images
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
                if let error { continuation.resume(throwing: error) }
                continuation.resume(returning: item as? UIImage)
            }
        }
    }
}
