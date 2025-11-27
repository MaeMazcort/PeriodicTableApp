//
//  FlashcardControlsView.swift
//  PeriodicTable
//
//  Enhanced control bar for the flashcard game
//

import SwiftUI
import UIKit

struct FlashcardControlsView: View {
    let isFlipped: Bool
    let canGoBack: Bool
    let onFlip: () -> Void
    let onKnow: () -> Void
    let onDontKnow: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Main action buttons
            HStack(spacing: 16) {
                // Don't know button
                Button(action: {
                    generateHaptic()
                    onDontKnow()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32, weight: .semibold))
                        
                        Text("No lo sé")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.4196, blue: 0.4196), Color(red: 0.9333, green: 0.3529, blue: 0.3216)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .shadow(color: Color(red: 1.0, green: 0.4196, blue: 0.4196).opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .disabled(!isFlipped)
                .opacity(isFlipped ? 1 : 0.5)
                
                // Know button
                Button(action: {
                    generateHaptic()
                    onKnow()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32, weight: .semibold))
                        
                        Text("Lo sé")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.3176, green: 0.8118, blue: 0.4), Color(red: 0.2157, green: 0.6980, blue: 0.3020)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .shadow(color: Color(red: 0.3176, green: 0.8118, blue: 0.4).opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .disabled(!isFlipped)
                .opacity(isFlipped ? 1 : 0.5)
            }
            
            // Secondary actions
            HStack(spacing: 16) {
                // Back button
                Button(action: {
                    generateHaptic()
                    onBack()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Atrás")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canGoBack)
                .opacity(canGoBack ? 1 : 0.5)
                
                // Flip button
                Button(action: {
                    generateHaptic()
                    onFlip()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(isFlipped ? "Pregunta" : "Respuesta")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.4941, blue: 0.9176), Color(red: 0.4627, green: 0.2941, blue: 0.6353)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.4, green: 0.4941, blue: 0.9176).opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.4, green: 0.4941, blue: 0.9176), Color(red: 0.4627, green: 0.2941, blue: 0.6353)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ).opacity(0.3),
                                lineWidth: 1.5
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    VStack {
        FlashcardControlsView(
            isFlipped: false,
            canGoBack: true,
            onFlip: {},
            onKnow: {},
            onDontKnow: {},
            onBack: {}
        )
        .padding()
        
        FlashcardControlsView(
            isFlipped: true,
            canGoBack: false,
            onFlip: {},
            onKnow: {},
            onDontKnow: {},
            onBack: {}
        )
        .padding()
    }
    .background(Color(.systemBackground))
}
