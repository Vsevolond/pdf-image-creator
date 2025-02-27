//
//  Shimmer.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 22.02.2025.
//

import SwiftUI

extension View {
    
    @ViewBuilder func shimmering(isActive: Bool = true) -> some View {
        if isActive {
            modifier(ShimmerModifier())
        } else {
            self
        }
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .onAppear {
                withAnimation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 0.7
                }
            }
    }
}

struct AnimatedMask: AnimatableModifier {
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .mask {
                GradientMask(phase: phase)
                    .scaleEffect(3)
            }
    }
}

struct GradientMask: View {
    let phase: CGFloat
    let centerColor = Color.primary.opacity(0.6)
    let edgeColor = Color.primary.opacity(0.3)
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]
            ),
            startPoint: UnitPoint(x: 0, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.5)
        )
    }
}
