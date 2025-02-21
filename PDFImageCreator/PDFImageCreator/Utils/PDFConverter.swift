//
//  PDFConverter.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import UIKit

protocol PDFConverter: AnyObject {
    func convert(images: [UIImage]) -> Data
}

final class PDFConverterImpl: PDFConverter {
    
    func convert(images: [UIImage]) -> Data {
        let pdfData = NSMutableData()
        var maxSize: CGSize = .zero
        
        for image in images {
            maxSize.width = max(maxSize.width, image.size.width)
            maxSize.height = max(maxSize.height, image.size.height)
        }
        
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for image in images {
            let pdfSize = image.size.expanded(to: maxSize)
            let pdfRect = CGRect(origin: .zero, size: pdfSize)
            
            UIGraphicsBeginPDFPageWithInfo(pdfRect, nil)
            
            image.draw(in: pdfRect)
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
}
