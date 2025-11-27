//
//  PairsResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Results screen for pairs matching game
//

import SwiftUI

struct PairsResultsView: View {
    let matchedPairs: Int
    let totalMoves: Int
    let totalTime: Int
    let difficulty: PairsDifficulty
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    @State private var showConfetti = false
    
    private var efficiency: Double {
        guard totalMoves > 0, matchedPairs > 0 else { return 0 }
        let perfectMoves = matchedPairs
        return min(Double(perfectMoves) / Double(totalMoves) * 100, 100)
    }
    
    private var stars: Int {
        if efficiency >= 90 { return 3 }
        else if efficiency >= 70 { return 2 }
        else { return 1 }
    }
    
    private var performanceMessage: String {
        switch stars {
        case 3: return "¡Memoria perfecta!"
        case 2: return "¡Muy bien hecho!"
        default: return "¡Buen trabajo!"
        }
    }
    
    private var performanceEmoji: String {
        switch stars {
        case 3: return "🏆"
        case 2: return "🌟"
        default: return "👍"
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Stars rating
                ZStack {
                    // Pulsing background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 20, x: 0, y: 10)
                        .scaleEffect(scale)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Image(systemName: index < stars ? "star.fill" : "star")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                        scale = 1.05
                    }
                    
                    if stars >= 2 {
                        showConfetti = true
                        generateNotificationHaptic(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showConfetti = false
                        }
                    }
                }
                
                // Title
                VStack(spacing: 12) {
                    Text(performanceEmoji)
                        .font(.system(size: 48))
                    
                    Text("¡Completado!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(performanceMessage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
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
                .foregroundStyle(Color(hex: difficulty.color))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color(hex: difficulty.color).opacity(0.15), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color(hex: difficulty.color).opacity(0.3), lineWidth: 1)
                }
                .opacity(showContent ? 1 : 0)
                
                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    statCard(
                        title: "Parejas",
                        value: "\(matchedPairs)",
                        icon: "checkmark.seal.fill",
                        color: Color(hex: "51cf66")
                    )
                    
                    statCard(
                        title: "Movimientos",
                        value: "\(totalMoves)",
                        icon: "hand.tap.fill",
                        color: Color(hex: "667eea")
                    )
                    
                    statCard(
                        title: "Eficiencia",
                        value: "\(Int(efficiency))%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: Color(hex: "ffa94d")
                    )
                    
                    statCard(
                        title: "Tiempo",
                        value: formattedTime,
                        icon: "clock.fill",
                        color: Color(hex: "ff6b6b")
                    )
                }
                .padding(.horizontal, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 14) {
                    Button {
                        generateHaptic(style: .light)
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
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        generateHaptic(style: .light)
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
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
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
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func generateNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hex: "667eea").opacity(0.12),
                Color(hex: "764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        PairsResultsView(
            matchedPairs: 10,
            totalMoves: 16,
            totalTime: 95,
            difficulty: .medium,
            onPlayAgain: {},
            onExit: {}
        )
    }
}
