//
//  LightningResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Results screen for lightning challenge
//

import SwiftUI
import UIKit

// Local hex color helper to avoid conflicting initializers
fileprivate func lrColor(_ hex: String) -> Color {
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

struct LightningResultsView: View {
    let correctCount: Int
    let incorrectCount: Int
    let totalPoints: Int
    let bestStreak: Int
    let averageTime: Double
    let questionsPerMinute: Double
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    @State private var showConfetti = false
    
    private var totalAnswered: Int {
        correctCount + incorrectCount
    }
    
    private var accuracy: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(correctCount) / Double(totalAnswered) * 100
    }
    
    private var performanceLevel: String {
        if correctCount >= 40 { return "¡Impresionante!" }
        else if correctCount >= 30 { return "¡Excelente!" }
        else if correctCount >= 20 { return "¡Muy bien!" }
        else if correctCount >= 10 { return "¡Buen trabajo!" }
        else { return "¡Sigue practicando!" }
    }
    
    private var performanceEmoji: String {
        if correctCount >= 40 { return "🏆" }
        else if correctCount >= 30 { return "🌟" }
        else if correctCount >= 20 { return "⚡" }
        else if correctCount >= 10 { return "💪" }
        else { return "📚" }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    // Achievement icon with points
                    achievementBadge
                    
                    // Title
                    VStack(spacing: 12) {
                        Text(performanceEmoji)
                            .font(.system(size: 56))
                        
                        Text("¡Tiempo completado!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(performanceLevel)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [lrColor("667eea"), lrColor("764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Main stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(
                            title: "Correctas",
                            value: "\(correctCount)",
                            icon: "checkmark.circle.fill",
                            color: lrColor("51cf66")
                        )
                        
                        statCard(
                            title: "Puntos",
                            value: "\(totalPoints)",
                            icon: "star.fill",
                            color: lrColor("ffd43b")
                        )
                        
                        statCard(
                            title: "Precisión",
                            value: "\(Int(accuracy))%",
                            icon: "target",
                            color: lrColor("667eea")
                        )
                        
                        statCard(
                            title: "Mejor Racha",
                            value: "\(bestStreak)",
                            icon: "flame.fill",
                            color: lrColor("ff6b6b")
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Performance metrics
                    performanceMetrics
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    // Achievements
                    if hasAchievements {
                        achievementsSection
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                    }
                    
                    // Action buttons
                    VStack(spacing: 14) {
                        Button {
                            generateHaptic(style: .light)
                            onPlayAgain()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Intentar de nuevo")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                LinearGradient(
                                    colors: [lrColor("667eea"), lrColor("764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                            .shadow(color: lrColor("667eea").opacity(0.4), radius: 12, x: 0, y: 6)
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
                LightningConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                showContent = true
            }
            
            if correctCount >= 30 {
                showConfetti = true
                generateSuccessHaptic()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                }
            }
        }
    }
    
    // MARK: - Achievement Badge
    private var achievementBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [lrColor("667eea"), lrColor("764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: lrColor("667eea").opacity(0.5), radius: 24, x: 0, y: 12)
                .scaleEffect(scale)
            
            VStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("\(totalPoints)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .numericTextTransitionIfAvailable()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
        }
    }
    
    // MARK: - Performance Metrics
    private var performanceMetrics: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(lrColor("667eea"))
                
                Text("Métricas de Rendimiento")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                metricRow(
                    icon: "timer",
                    label: "Tiempo promedio",
                    value: String(format: "%.1fs", averageTime),
                    color: lrColor("ffa94d")
                )
                
                metricRow(
                    icon: "speedometer",
                    label: "Preguntas por minuto",
                    value: String(format: "%.1f", questionsPerMinute),
                    color: lrColor("667eea")
                )
                
                metricRow(
                    icon: "list.number",
                    label: "Total respondidas",
                    value: "\(totalAnswered)",
                    color: lrColor("764ba2")
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func metricRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        }
    }
    
    // MARK: - Achievements
    private var hasAchievements: Bool {
        bestStreak >= 5 || correctCount >= 30 || accuracy >= 90
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(lrColor("ffd43b"))
                
                Text("Logros Desbloqueados")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                if bestStreak >= 10 {
                    achievementBadge(
                        icon: "flame.fill",
                        title: "Racha Legendaria",
                        description: "\(bestStreak) respuestas correctas seguidas",
                        color: lrColor("ff6b6b")
                    )
                } else if bestStreak >= 5 {
                    achievementBadge(
                        icon: "flame.fill",
                        title: "En Racha",
                        description: "\(bestStreak) respuestas correctas seguidas",
                        color: lrColor("ffa94d")
                    )
                }
                
                if correctCount >= 40 {
                    achievementBadge(
                        icon: "bolt.fill",
                        title: "Maestro del Rayo",
                        description: "40+ respuestas correctas en 60 segundos",
                        color: lrColor("ffd43b")
                    )
                } else if correctCount >= 30 {
                    achievementBadge(
                        icon: "star.fill",
                        title: "Velocista",
                        description: "30+ respuestas correctas",
                        color: lrColor("667eea")
                    )
                }
                
                if accuracy >= 90 {
                    achievementBadge(
                        icon: "target",
                        title: "Precisión Perfecta",
                        description: "\(Int(accuracy))% de precisión",
                        color: lrColor("51cf66")
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func achievementBadge(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.3), lineWidth: 1.5)
        }
        .shadow(color: color.opacity(0.15), radius: 12, x: 0, y: 6)
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
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
                .numericTextTransitionIfAvailable()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
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
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func generateSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Confetti View
struct LightningConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                LightningConfettiPiece()
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

struct LightningConfettiPiece: View {
    let colors: [Color] = [
        lrColor("667eea"),
        lrColor("764ba2"),
        lrColor("f093fb"),
        lrColor("51cf66"),
        lrColor("ff6b6b"),
        lrColor("ffd43b")
    ]
    
    var body: some View {
        Circle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
    }
}

// MARK: - View Extension for numericTextTransition
extension View {
    @ViewBuilder
    func numericTextTransitionIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            self.contentTransition(.numericText())
        } else {
            self
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                lrColor("667eea").opacity(0.12),
                lrColor("764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        LightningResultsView(
            correctCount: 35,
            incorrectCount: 8,
            totalPoints: 985,
            bestStreak: 12,
            averageTime: 2.3,
            questionsPerMinute: 43.0,
            onPlayAgain: {},
            onExit: {}
        )
    }
}
