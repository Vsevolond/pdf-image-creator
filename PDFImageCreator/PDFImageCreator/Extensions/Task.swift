//
//  Task.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation

extension Task where Failure == Never {
    
    @discardableResult
    static func delayed(
        byTimeInterval delayInterval: TimeInterval,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success
    ) -> Task {
        Task(priority: priority) {
            let delay = UInt64(delayInterval * 1_000_000_000)
            try? await Task<Never, Never>.sleep(nanoseconds: delay)
            
            return await operation()
        }
    }
}
