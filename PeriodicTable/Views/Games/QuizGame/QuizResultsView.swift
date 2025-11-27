//
//  QuizResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego on 26/11/25.
//


//
//  QuizResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Quiz results screen with celebration and detailed stats
//

import SwiftUI

struct QuizResultsView: View {
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: Int
    let difficulty: QuizDifficulty
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    @State private var showConfetti = false
    
    private var totalQuestions: Int {
        correctCount + incorrectCount
    }
    
    private var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions) * 100
    }
    
    private var grade: String {
        switch accuracy {
        case 95...100: return "A+"
        case 90..<95: return "A"
        case 85..<90: return "A-"
        case 80..<85: return "B+"
        case 75..<80: return "B"
        case 70..<75: return "B-"
        case 65..<70: return "C+"
        case 60..<65: return "C"
        default: return "D"
        }
    }
    
    private var performanceMessage: String {
        switch accuracy {
        case 95...100: return "¡Perfecto! Eres un maestro"
        case 85..<95: return "¡Excelente trabajo!"
        case 70..<85: return "¡Muy bien hecho!"
        case 50..<70: return "¡Buen esfuerzo!"
        default: return "¡Sigue practicando!"
        }
    }
    
    private var performanceEmoji: String {
        switch accuracy {
        case 95...100: return "🏆"
        case 85..<95: return "🌟"
        case 70..<85: return "🎯"
        case 50..<70: return "💪"
        default: return "📚"
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Grade circle
                ZStack {
                    // Pulsing background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color(hexString: "667eea").opacity(0.5), radius: 20, x: 0, y: 10)
                        .scaleEffect(scale)
                    
                    VStack(spacing: 4) {
                        Text(grade)
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("\(Int(accuracy))%")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                        scale = 1.05
                    }
                    
                    if accuracy >= 80 {
                        showConfetti = true
                        HapticManager.notification(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showConfetti = false
                        }
                    }
                }
                
                // Title with emoji
                VStack(spacing: 12) {
                    Text(performanceEmoji)
                        .font(.system(size: 48))
                    
                    Text("¡Quiz Completado!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(performanceMessage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Difficulty badge
                HStack(spacing: 8) {
                    Image(systemName: difficulty.icon)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Dificultad: \(difficulty.rawValue)")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(Color(hexString: difficulty.color))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color(hexString: difficulty.color).opacity(0.15), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color(hexString: difficulty.color).opacity(0.3), lineWidth: 1)
                }
                .opacity(showContent ? 1 : 0)
                
                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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
                    
                    statCard(
                        title: "Total",
                        value: "\(totalQuestions)",
                        icon: "number.circle.fill",
                        color: Color(hexString: "667eea")
                    )
                    
                    statCard(
                        title: "Tiempo",
                        value: formattedTime,
                        icon: "clock.fill",
                        color: Color(hexString: "ffa94d")
                    )
                }
                .padding(.horizontal, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 14) {
                    Button {
                        HapticManager.impact(.light)
                        onPlayAgain()
                    } label: {
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
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .shadow(color: Color(hexString: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        HapticManager.impact(.light)
                        onExit()
                    } label: {
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
            
            // Confetti overlay
            if showConfetti {
                CelebrationConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
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
        if mins > 0 {
            return "\(mins):\(String(format: "%02d", secs))"
        } else {
            return "\(secs)s"
        }
    }
}


// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.12),
                Color(hexString: "764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            QuizResultsView(
                correctCount: 9,
                incorrectCount: 1,
                totalTime: 125,
                difficulty: .medium,
                onPlayAgain: {},
                onExit: {}
            )
        }
    }
}

