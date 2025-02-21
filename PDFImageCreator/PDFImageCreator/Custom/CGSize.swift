//
//  CGSize.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation

extension CGSize {
    
    func expanded(to size: CGSize) -> CGSize {
        guard size.width >= width && size.height >= height else { return self }
        
        let ratioX = size.width / width
        let ratioY = size.height / height
        let ratio = min(ratioX, ratioY)
        
        return CGSize(width: width * ratio, height: height * ratio)
    }
}
