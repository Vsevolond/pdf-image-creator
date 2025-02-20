//
//  GalleryImagePicker.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI
import PhotosUI

struct GalleryImagePicker: UIViewControllerRepresentable {
    
    private let config: PHPickerConfiguration = {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        
        config.filter = .images
//        config.selectionLimit = 10
        config.preferredAssetRepresentationMode = .current
        
        return config
    }()
    
    @Binding var isPresented: Bool
    
    let completion: (_ results: [PHPickerResult]) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PHPickerViewController(configuration: config)
        viewController.delegate = context.coordinator
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(imagePicker: self) }
    
    final class Coordinator: PHPickerViewControllerDelegate {
        
        let imagePicker: GalleryImagePicker
        
        init(imagePicker: GalleryImagePicker) {
            self.imagePicker = imagePicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            imagePicker.isPresented = false
            imagePicker.completion(results)
        }
    }
}
