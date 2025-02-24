//
//  Spinner.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI

struct Spinner: View {
    let lineWidth: CGFloat
    let color: Color
    
    @State private var length: CGFloat = 0.8
    @State private var degree: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0.1, to: length)
            .stroke(color, style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            ))
            .rotationEffect(.degrees(degree))
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    length = 0.2
                }

                withAnimation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false)
                ) {
                    degree += 360
                }
            }
    }
}

struct SaveSpinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner(lineWidth: 10, color: .indigo)
            .frame(width: 100, height: 100)
    }
}
