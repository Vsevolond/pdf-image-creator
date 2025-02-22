//
//  StorageService.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation
import RealmSwift
import os

enum StorageServiceError: Error {
    case savingFailed
    case noObject
    case deletingFailed
    case fetchingFailed
}

protocol StorageService: AnyObject {
    func save(object: FileModelObject) async throws
    func delete(id: UUID) async throws
    func fetch() async throws -> [FileModelObject]
}

final class StorageServiceImpl: StorageService {
    
    private let manager = FileManager.default
    
    private lazy var logger = os.Logger(subsystem: Bundle.main.appId, category: "StorageService")
    
    func save(object: FileModelObject) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let store = try Realm()
                
                try store.write {
                    store.add(object)
                }
                log("object saved")
                continuation.resume()
                
            } catch {
                log("object saving error: \(error)")
                continuation.resume(throwing: StorageServiceError.savingFailed)
            }
        }
    }
    
    func delete(id: UUID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let store = try Realm()
                
                if let object = store.object(ofType: FileModelObject.self, forPrimaryKey: id) {
                    try store.write {
                        store.delete(object)
                    }
                    log("object deleted")
                    continuation.resume()
                    
                } else {
                    log("no object for id: \(id)")
                    continuation.resume(throwing: StorageServiceError.noObject)
                }
                
            } catch {
                log("object deleting error: \(error)")
                continuation.resume(throwing: StorageServiceError.deletingFailed)
            }
        }
    }
    
    func fetch() async throws -> [FileModelObject] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let store = try Realm()
                let objects = store.objects(FileModelObject.self).toArray()
                
                log("fetched objects")
                continuation.resume(returning: objects)
                
            } catch {
                log("fetching error: \(error)")
                continuation.resume(throwing: StorageServiceError.fetchingFailed)
            }
        }
    }
    
    private func log(_ message: String) {
        logger.log("💿 StorageService: \(message)")
    }
}

private extension Results {
    func toArray() -> [Element] {
        Array(self)
    }
}
