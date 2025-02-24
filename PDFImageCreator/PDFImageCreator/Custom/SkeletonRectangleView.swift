//
//  SkeletonRectangleView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 24.02.2025.
//

import SwiftUI

struct SkeletonRectangleView: View {
    let cornerRadius: CGFloat = 8
    let blurRadius: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.gray)
            .blur(radius: blurRadius)
            .shimmering()
    }
}
