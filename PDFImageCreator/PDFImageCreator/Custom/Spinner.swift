//
//  Spinner.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 21.02.2025.
//

import SwiftUI

import SwiftUI

struct Spinner: View {
    let count: Int
    let size: CGFloat
    let color: Color
    
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    item(forIndex: index, in: geometry.size)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        }
        .aspectRatio(contentMode: .fit)
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }

    private func item(forIndex index: Int, in geometrySize: CGSize) -> some View {
        let angle = 2 * CGFloat.pi / CGFloat(count) * CGFloat(index)
        let radius = (geometrySize.width / 2 - size / 2)
        let x = radius * cos(angle)
        let y = radius * sin(angle)

        return Circle()
            .frame(width: size, height: size)
            .foregroundStyle(color)
            .scaleEffect(isAnimating ? 0.3 : 1)
            .opacity(isAnimating ? 0.25 : 1)
            .offset(x: x, y: y)
            .animation(
                .easeInOut(duration: 1)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) / Double(count)),
                value: isAnimating
            )
    }
}

struct SaveSpinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner(count: 8, size: 20, color: .indigo)
            .frame(width: 100, height: 100, alignment: .center)
    }
}
