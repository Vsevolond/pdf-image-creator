//
//  FileSaver.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 22.02.2025.
//

import Foundation
import os

enum FileHelperError: Error {
    case fileExists
    case noDirectoryUrl
    case savingFailed
    case deletingFailed
}

protocol FileHelper: AnyObject {
    
    func tryToSaveFile(withName name: String, from url: URL) async throws -> URL
    func deleteFile(at url: URL) async throws
}

final class FileHelperImpl: FileHelper {
    
    private let manager = FileManager.default
    
    private lazy var logger = os.Logger(subsystem: Bundle.main.appId, category: "FileSaver")
    
    func tryToSaveFile(withName name: String, from url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            guard let directoryUrl = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                log("no documents directory in user domain mask")
                continuation.resume(throwing: FileHelperError.noDirectoryUrl)
                return
            }
            
            let newUrl = directoryUrl.appendingPathComponent("\(name).pdf")
            guard !manager.fileExists(atPath: newUrl.path) else {
                log("file with same name{\(name)} already exists")
                continuation.resume(throwing: FileHelperError.fileExists)
                return
            }
            
            do {
                try manager.copyItem(at: url, to: newUrl)
                continuation.resume(returning: newUrl)
                
            } catch {
                log("error in copying: \(error)")
                continuation.resume(throwing: FileHelperError.savingFailed)
            }
        }
    }
    
    func deleteFile(at url: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try manager.removeItem(at: url)
                continuation.resume()
                
            } catch {
                log("deleting failed: \(error)")
                continuation.resume(throwing: FileHelperError.deletingFailed)
            }
        }
    }
    
    private func log(_ message: String) {
        logger.log("💾 FileSaver: \(message)")
    }
}
