//
//  BingoResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Victory screen with patterns achieved
//

import SwiftUI

// Local hex color helper to avoid conflicting initializers
fileprivate func brColor(_ hex: String) -> Color {
    var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hexString).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hexString.count {
    case 3: // RGB (12-bit)
        (a, r, g, b) = (255, (int >> 8) * 17, ((int >> 4) & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
        (a, r, g, b) = (255, int >> 16, (int >> 8) & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
        (a, r, g, b) = (int >> 24, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
    default:
        (a, r, g, b) = (255, 0, 0, 0)
    }
    return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
}

struct BingoResultsView: View {
    let patterns: [BingoWinPattern]
    let totalTime: Int
    let markedCount: Int
    let totalCalled: Int
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    @State private var showConfetti = true
    
    private var totalPoints: Int {
        patterns.reduce(0) { $0 + $1.points }
    }
    
    private var hasFullCard: Bool {
        patterns.contains(.fullCard)
    }
    
    private var mainPattern: BingoWinPattern {
        if hasFullCard {
            return .fullCard
        } else {
            return patterns.first ?? .horizontal1
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    // Victory badge
                    victoryBadge
                    
                    // Title
                    VStack(spacing: 12) {
                        Text(hasFullCard ? "🎉" : "🌟")
                            .font(.system(size: 64))
                        
                        Text(hasFullCard ? "¡BINGO!" : "¡Patrón Completo!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(hasFullCard ? "¡Cartón completo!" : "¡Sigue jugando!")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [brColor("667eea"), brColor("764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Main stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(
                            title: "Puntos",
                            value: "\(totalPoints)",
                            icon: "star.fill",
                            color: brColor("ffd43b")
                        )
                        
                        statCard(
                            title: "Marcados",
                            value: "\(markedCount)/25",
                            icon: "checkmark.seal.fill",
                            color: brColor("51cf66")
                        )
                        
                        statCard(
                            title: "Tiempo",
                            value: formattedTime,
                            icon: "clock.fill",
                            color: brColor("ffa94d")
                        )
                        
                        statCard(
                            title: "Cantados",
                            value: "\(totalCalled)",
                            icon: "number",
                            color: brColor("667eea")
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Patterns achieved
                    patternsSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    // Action buttons
                    VStack(spacing: 14) {
                        Button {
                            generateHaptic(style: .light)
                            onPlayAgain()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Nuevo Juego")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                LinearGradient(
                                    colors: [brColor("667eea"), brColor("764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                            .shadow(color: brColor("667eea").opacity(0.4), radius: 12, x: 0, y: 6)
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
            
            generateSuccessHaptic()
            
            // Stop confetti after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showConfetti = false
            }
        }
    }
    
    // MARK: - Victory Badge
    private var victoryBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [brColor("ffd43b"), brColor("ffa94d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: brColor("ffd43b").opacity(0.5), radius: 24, x: 0, y: 12)
                .scaleEffect(scale)
            
            VStack(spacing: 4) {
                Image(systemName: mainPattern.icon)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("\(totalPoints)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
        }
    }
    
    // MARK: - Patterns Section
    private var patternsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(brColor("ffd43b"))
                
                Text("Patrones Completados")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(patterns, id: \.rawValue) { pattern in
                    patternCard(pattern)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func patternCard(_ pattern: BingoWinPattern) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(brColor("ffd43b").opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: pattern.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(brColor("ffd43b"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.shortName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("+\(pattern.points) puntos")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(brColor("51cf66"))
        }
        .padding(16)
        .background(brColor("ffd43b").opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(brColor("ffd43b").opacity(0.4), lineWidth: 2)
        }
        .shadow(color: brColor("ffd43b").opacity(0.15), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Stat Card
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .monospacedDigit()
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
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
    
    private func generateSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                brColor("667eea").opacity(0.12),
                brColor("764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        BingoResultsView(
            patterns: [.horizontal1, .vertical2, .diagonal1, .fullCard],
            totalTime: 245,
            markedCount: 25,
            totalCalled: 45,
            onPlayAgain: {},
            onExit: {}
        )
    }
}
