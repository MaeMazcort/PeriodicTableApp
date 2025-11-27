//
//  FlashcardResultsView.swift
//  PeriodicTable
//
//  Enhanced end-of-game result summary with celebration design
//

import SwiftUI

struct FlashcardResultsView: View {
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: Int
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    
    static let gradientStart = Color(hexString: "667eea")
    static let gradientEnd = Color(hexString: "764ba2")
    
    private var totalCards: Int {
        correctCount + incorrectCount
    }
    
    private var accuracy: Double {
        guard totalCards > 0 else { return 0 }
        return Double(correctCount) / Double(totalCards) * 100
    }
    
    private func performanceMessage(for accuracy: Double) -> String {
        let acc = max(0, min(100, accuracy))
        if acc >= 90 { return "¡Excelente trabajo!" }
        else if acc >= 70 { return "¡Muy bien!" }
        else if acc >= 50 { return "¡Buen esfuerzo!" }
        else { return "¡Sigue practicando!" }
    }

    private func performanceEmoji(for accuracy: Double) -> String {
        let acc = max(0, min(100, accuracy))
        if acc >= 90 { return "🌟" }
        else if acc >= 70 { return "🎯" }
        else if acc >= 50 { return "💪" }
        else { return "📚" }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated completion icon
            ZStack {
                // Pulsing background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Self.gradientStart, Self.gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hexString: "667eea").opacity(0.5), radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
            
            // Title with emoji
            VStack(spacing: 12) {
                Text(performanceEmoji(for: accuracy))
                    .font(.system(size: 48))
                
                Text("¡Completado!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(performanceMessage(for: accuracy))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Self.gradientStart, Self.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            // Stats cards
            HStack(spacing: 16) {
                statCard(
                    title: "Correctas",
                    value: "\(correctCount)",
                    icon: "checkmark.circle.fill",
                    color: Color(hexString: "51cf66")
                )
                
                statCard(
                    title: "Incorrectas",
                    value: "\(incorrectCount)",
                    icon: "xmark.circle.fill",
                    color: Color(hexString: "ff6b6b")
                )
            }
            .padding(.horizontal, 20)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            // Additional stats
            VStack(spacing: 12) {
                // Accuracy
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hexString: "667eea"))
                    
                    Text("Precisión:")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(accuracy))%")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Time
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text("Tiempo:")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(formattedTime)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 14) {
                Button(action: {
                    generateHaptic()
                    onPlayAgain()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Jugar de nuevo")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        LinearGradient(
                            colors: [Self.gradientStart, Self.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: Color(hexString: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    generateHaptic()
                    onExit()
                }) {
                    Text("Salir")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.25), lineWidth: 1.5)
        }
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    private var formattedTime: String {
        let mins = totalTime / 60
        let secs = totalTime % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                FlashcardResultsView.gradientStart.opacity(0.12),
                FlashcardResultsView.gradientEnd.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            FlashcardResultsView(
                correctCount: 8,
                incorrectCount: 2,
                totalTime: 125,
                onPlayAgain: {},
                onExit: {}
            )
            
            FlashcardResultsView(
                correctCount: 5,
                incorrectCount: 5,
                totalTime: 95,
                onPlayAgain: {},
                onExit: {}
            )
        }
    }
}

