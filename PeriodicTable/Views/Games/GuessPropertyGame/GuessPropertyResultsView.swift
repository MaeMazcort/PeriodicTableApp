//
//  GuessPropertyResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Results screen with accuracy breakdown
//

import SwiftUI

struct GuessPropertyResultsView: View {
    let totalScore: Int
    let averageScore: Double
    let averageError: Double
    let totalTime: Int
    let excellentCount: Int
    let goodCount: Int
    let okCount: Int
    let fairCount: Int
    let poorCount: Int
    let propertyStats: [PropertyType: (totalError: Double, count: Int)]
    let difficulty: GuessPropertyDifficulty
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    @State private var showConfetti = false
    
    private var performanceLevel: String {
        if averageScore >= 90 { return "¡Excelente estimador!" }
        else if averageScore >= 75 { return "¡Muy buena precisión!" }
        else if averageScore >= 60 { return "¡Buen trabajo!" }
        else { return "¡Sigue practicando!" }
    }
    
    private var performanceEmoji: String {
        if averageScore >= 90 { return "🎯" }
        else if averageScore >= 75 { return "🌟" }
        else if averageScore >= 60 { return "📊" }
        else { return "📚" }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    // Score badge
                    scoreBadge
                    
                    // Title
                    VStack(spacing: 12) {
                        Text(performanceEmoji)
                            .font(.system(size: 56))
                        
                        Text("¡Completado!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(performanceLevel)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0.0 : 20.0)
                    
                    // Difficulty badge
                    difficultyBadge
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    // Main stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        statCard(
                            title: "Puntos",
                            value: "\(totalScore)",
                            icon: "star.fill",
                            color: Color(hexString: "ffd43b")
                        )
                        
                        statCard(
                            title: "Precisión",
                            value: "\(Int(averageScore))%",
                            icon: "target",
                            color: Color(hexString: "667eea")
                        )
                        
                        statCard(
                            title: "Error Prom.",
                            value: String(format: "±%.1f%%", averageError),
                            icon: "arrow.left.and.right",
                            color: Color(hexString: "ffa94d")
                        )
                        
                        statCard(
                            title: "Tiempo",
                            value: formattedTime,
                            icon: "clock.fill",
                            color: Color(hexString: "764ba2")
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0.0 : 20.0)
                    
                    // Accuracy breakdown
                    accuracyBreakdown
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0.0 : 20.0)
                    
                    // Property stats
                    if !propertyStats.isEmpty {
                        propertyStatsSection
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0.0 : 20.0)
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
                                
                                Text("Jugar de Nuevo")
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
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0.0 : 20.0)
                }
            }
            
            // Confetti
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
            
            if averageScore >= 75 {
                showConfetti = true
                generateNotificationHaptic(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                }
            }
        }
    }
    
    // MARK: - Score Badge
    private var scoreBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hexString: "ffd43b"), Color(hexString: "ffa94d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: Color(hexString: "ffd43b").opacity(0.5), radius: 24, x: 0, y: 12)
                .scaleEffect(scale)
            
            VStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("\(totalScore)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .numericTextTransition()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
        }
    }
    
    // MARK: - Difficulty Badge
    private var difficultyBadge: some View {
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
    }
    
    // MARK: - Accuracy Breakdown
    private var accuracyBreakdown: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: "667eea"))
                
                Text("Desglose de Precisión")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                if excellentCount > 0 {
                    accuracyRow(
                        level: .excellent,
                        count: excellentCount,
                        label: "Excelente (±5%)"
                    )
                }
                
                if goodCount > 0 {
                    accuracyRow(
                        level: .good,
                        count: goodCount,
                        label: "Muy Bien (±15%)"
                    )
                }
                
                if okCount > 0 {
                    accuracyRow(
                        level: .ok,
                        count: okCount,
                        label: "Bien (±30%)"
                    )
                }
                
                if fairCount > 0 {
                    accuracyRow(
                        level: .fair,
                        count: fairCount,
                        label: "Regular (±50%)"
                    )
                }
                
                if poorCount > 0 {
                    accuracyRow(
                        level: .poor,
                        count: poorCount,
                        label: "Mejora (+50%)"
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func accuracyRow(level: AccuracyLevel, count: Int, label: String) -> some View {
        HStack(spacing: 12) {
            Text(level.emoji)
                .font(.system(size: 24))
            
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hexString: level.color))
                .monospacedDigit()
        }
        .padding(14)
        .background(Color(hexString: level.color).opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hexString: level.color).opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Property Stats
    private var propertyStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: "764ba2"))
                
                Text("Por Propiedad")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                ForEach(propertyStats.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { property in
                    if let stats = propertyStats[property] {
                        let avgError = stats.totalError / Double(stats.count)
                        propertyStatRow(property: property, avgError: avgError, count: stats.count)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func propertyStatRow(property: PropertyType, avgError: Double, count: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hexString: property.color).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: property.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: property.color))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(property.rawValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("\(count) pregunta\(count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "±%.1f%%", avgError))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hexString: property.color))
                .monospacedDigit()
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
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
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.primary)
                .numericTextTransition()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .monospacedDigit()
            
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

// MARK: - Compatibility Helpers
fileprivate extension View {
    @ViewBuilder
    func numericTextTransition() -> some View {
        if #available(iOS 17.0, *) {
            self.contentTransition(.numericText())
        } else {
            self
        }
    }
}

