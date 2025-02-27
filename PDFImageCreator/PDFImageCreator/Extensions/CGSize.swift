//
//  CGSize.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import Foundation

extension CGSize {
    
    func expanded(toWidth width: CGFloat) -> CGSize {
        guard width > self.width else { return self }
        
        let ratio = width / self.width
        
        return CGSize(width: width, height: self.height * ratio)
    }
}
