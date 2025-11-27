//
//  PairsCardView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Individual card component with flip animation
//

import SwiftUI

struct PairsCardView: View {
    let card: PairsCard
    let onTap: () -> Void
    
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Back of card (shown when not flipped)
                if !card.isFlipped && !card.isMatched {
                    cardBack
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
                
                // Front of card (shown when flipped or matched)
                if card.isFlipped || card.isMatched {
                    cardFront
                        .rotation3DEffect(
                            .degrees(rotation + 180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onTapGesture {
                if !card.isFlipped && !card.isMatched {
                    generateHaptic()
                    onTap()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        rotation += 180
                    }
                }
            }
            .onChange(of: card.isFlipped) { _, newValue in
                if !newValue && !card.isMatched {
                    // Flip back animation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        rotation -= 180
                    }
                }
            }
        }
        .aspectRatio(0.7, contentMode: .fit)
    }
    
    // MARK: - Card Back
    private var cardBack: some View {
        let gradientColors: [Color] = [
            Color(red: 0.4, green: 0.494, blue: 0.918).opacity(0.8),
            Color(red: 0.463, green: 0.294, blue: 0.635).opacity(0.9)
        ]
        
        return ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Pattern
            VStack(spacing: 8) {
                Image(systemName: "atom")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text("?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    // MARK: - Card Front
    private var cardFront: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            card.isMatched
                            ? Color(red: 0.318, green: 0.812, blue: 0.4).opacity(0.6)
                            : Color.white.opacity(0.3),
                            lineWidth: card.isMatched ? 3 : 2
                        )
                }
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Content based on card type
            VStack(spacing: 8) {
                // Icon
                Image(systemName: card.type.isSymbol ? "character.textbox" : "number.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        card.isMatched
                        ? AnyShapeStyle(Color(red: 0.318, green: 0.812, blue: 0.4))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [Color(red: 0.4, green: 0.494, blue: 0.918), Color(red: 0.463, green: 0.294, blue: 0.635)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
                
                // Main text
                Text(card.type.displayText)
                    .font(.system(size: card.type.isSymbol ? 36 : 32, weight: .bold))
                    .foregroundStyle(
                        card.isMatched
                        ? Color(red: 0.318, green: 0.812, blue: 0.4)
                        : .primary
                    )
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                // Label
                Text(card.type.isSymbol ? "Símbolo" : "Número")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .padding(8)
            
            // Match indicator
            if card.isMatched {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(red: 0.318, green: 0.812, blue: 0.4))
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
        .scaleEffect(card.isMatched ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isMatched)
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview
struct PairsCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                PairsCardView(
                    card: PairsCard(
                        elementId: 1,
                        elementName: "Hidrógeno",
                        type: .symbol("H")
                    ),
                    onTap: {}
                )
                .frame(width: 100, height: 140)
                
                PairsCardView(
                    card: PairsCard(
                        elementId: 1,
                        elementName: "Hidrógeno",
                        type: .atomicNumber(1),
                        isFlipped: true
                    ),
                    onTap: {}
                )
                .frame(width: 100, height: 140)
                
                PairsCardView(
                    card: PairsCard(
                        elementId: 1,
                        elementName: "Hidrógeno",
                        type: .symbol("H"),
                        isFlipped: true,
                        isMatched: true
                    ),
                    onTap: {}
                )
                .frame(width: 100, height: 140)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.494, blue: 0.918).opacity(0.12),
                    Color(red: 0.463, green: 0.294, blue: 0.635).opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
