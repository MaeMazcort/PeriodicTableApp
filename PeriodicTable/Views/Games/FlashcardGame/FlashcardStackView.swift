//
//  FlashcardStackView.swift
//  PeriodicTable
//
//  Enhanced flashcard display with modern design and animations
//

import SwiftUI

struct FlashcardStackView: View {
    let flashcards: [Flashcard]
    let currentIndex: Int
    @Binding var isFlipped: Bool
    let onSpeak: (String) -> Void
    
    @State private var cardRotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background cards for depth effect
            ForEach(0..<min(3, flashcards.count - currentIndex), id: \.self) { index in
                if currentIndex + index < flashcards.count {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .scaleEffect(1 - (CGFloat(index) * 0.04))
                        .offset(y: CGFloat(index) * 10)
                        .opacity(1 - (Double(index) * 0.25))
                        .zIndex(-Double(index))
                }
            }
            
            // Main flashcard
            if !flashcards.isEmpty, currentIndex < flashcards.count {
                mainFlashcard
            } else {
                emptyState
            }
        }
        .frame(height: 420)
        .padding(.horizontal, 24)
    }
    
    private var mainFlashcard: some View {
        let flashcard = flashcards[currentIndex]
        
        return ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 12)
            
            // Content
            VStack(spacing: 24) {
                if !isFlipped {
                    // Front side - Question
                    frontSide(flashcard: flashcard)
                } else {
                    // Back side - Answer
                    backSide(flashcard: flashcard)
                }
            }
            .padding(.vertical, 40)
        }
        .rotation3DEffect(
            .degrees(cardRotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .scaleEffect(scale)
        .onTapGesture {
            flipCard()
        }
    }
    
    private func frontSide(flashcard: Flashcard) -> some View {
        VStack(spacing: 20) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.2),
                                Color(hexString: "764ba2").opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                
                Image(systemName: "atom")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Question text
            Text(flashcard.question)
                .font(.system(size: 36, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            
            Text("¿Cuál es el símbolo?")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 28)
        .transition(.opacity)
    }
    
    private func backSide(flashcard: Flashcard) -> some View {
        VStack(spacing: 20) {
            // Answer badge
            Text("SÍMBOLO")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
            
            // Answer text
            Text(flashcard.answer)
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Element name reference
            Text(flashcard.question)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // TTS button
            Button {
                onSpeak(flashcard.answer)
                generateHaptic()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Escuchar pronunciación")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(hexString: "667eea"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hexString: "667eea").opacity(0.1), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 28)
        .transition(.opacity)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text("No hay tarjetas disponibles")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
    }
    
    private func flipCard() {
        generateHaptic()
        
        // Add bounce effect
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 0.95
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cardRotation += 180
        }
        
        // Reset scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
            }
            isFlipped.toggle()
        }
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    @State var flipped = false
    let sample = [
        Flashcard(id: 1, question: "Hidrógeno", answer: "H"),
        Flashcard(id: 2, question: "Helio", answer: "He"),
        Flashcard(id: 3, question: "Litio", answer: "Li")
    ]
    
    return ZStack {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.12),
                Color(hexString: "764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        FlashcardStackView(
            flashcards: sample,
            currentIndex: 0,
            isFlipped: $flipped,
            onSpeak: { _ in }
        )
    }
}
