//
//  ConfettiView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct CelebrationConfettiView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                CelebrationConfettiPiece()
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: isAnimating ? 1000 : -100
                    )
                    .rotationEffect(.degrees(isAnimating ? 720 : 0))
                    .animation(
                        .linear(duration: Double.random(in: 2...4))
                        .delay(Double.random(in: 0...0.5)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct CelebrationConfettiPiece: View {
    // Merged palette from both previous implementations
    private static let palette: [Color] = [
        Color(hexString: "667eea"),
        Color(hexString: "764ba2"),
        Color(hexString: "f093fb"),
        Color(hexString: "51cf66"),
        Color(hexString: "ff6b6b"),
        Color(hexString: "ffa94d")
    ]

    private let size: CGFloat
    private let color: Color

    init() {
        // Choose deterministic values at init time to avoid ambiguous type inference in the body
        self.size = CGFloat.random(in: 6...12)
        self.color = Self.palette.randomElement() ?? Color(hexString: "667eea")
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}
