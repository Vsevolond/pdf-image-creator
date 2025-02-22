//
//  DocumentImagePicker.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI
import PhotosUI

struct DocumentImagePicker: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    let completion: (_ results: [URL]) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let documentTypes: [UTType] = [.png, .jpeg]
        let viewController = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes, asCopy: true)
        viewController.allowsMultipleSelection = true
        viewController.delegate = context.coordinator
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(imagePicker: self) }
    
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let imagePicker: DocumentImagePicker
        
        init(imagePicker: DocumentImagePicker) {
            self.imagePicker = imagePicker
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            imagePicker.isPresented = false
            imagePicker.completion(urls)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            imagePicker.isPresented = false
        }
    }
}
