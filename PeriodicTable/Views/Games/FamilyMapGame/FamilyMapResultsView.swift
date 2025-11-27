//
//  FamilyMapResultsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Results screen with family statistics
//

import SwiftUI
import UIKit

struct FamilyMapResultsView: View {
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: Int
    let difficulty: FamilyMapDifficulty
    let familyStats: [ChemicalFamily: (correct: Int, total: Int)]
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.8
    @State private var showConfetti = false
    
    private var totalElements: Int {
        correctCount + incorrectCount
    }
    
    private var accuracy: Double {
        guard totalElements > 0 else { return 0 }
        return Double(correctCount) / Double(totalElements) * 100
    }
    
    private var performanceMessage: String {
        switch accuracy {
        case 90...100: return "¡Excelente clasificación!"
        case 75..<90: return "¡Muy bien hecho!"
        case 60..<75: return "¡Buen trabajo!"
        default: return "¡Sigue practicando!"
        }
    }
    
    private var performanceEmoji: String {
        switch accuracy {
        case 90...100: return "🏆"
        case 75..<90: return "🌟"
        case 60..<75: return "💪"
        default: return "📚"
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)
                    
                    // Achievement icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
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
                        
                        if accuracy >= 75 {
                            showConfetti = true
                            generateHaptic(style: .soft)
                            
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
                    
                    // Main stats
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
                            title: "Precisión",
                            value: "\(Int(accuracy))%",
                            icon: "chart.bar.fill",
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
                    
                    // Family breakdown
                    if !familyStats.isEmpty {
                        familyStatsSection
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
        }
    }
    
    // MARK: - Family Stats Section
    private var familyStatsSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: "667eea"))
                
                Text("Por Familia")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Family stats list
            VStack(spacing: 12) {
                ForEach(familyStats.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { family in
                    if let stats = familyStats[family] {
                        familyStatRow(family: family, correct: stats.correct, total: stats.total)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func familyStatRow(family: ChemicalFamily, correct: Int, total: Int) -> some View {
        HStack(spacing: 12) {
            // Family icon
            ZStack {
                Circle()
                    .fill(Color(hexString: family.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: family.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: family.color))
            }
            
            // Family name
            Text(family.shortName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            
            Spacer()
            
            // Stats
            HStack(spacing: 6) {
                Text("\(correct)/\(total)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                
                // Percentage
                let percentage = total > 0 ? Int(Double(correct) / Double(total) * 100) : 0
                Text("(\(percentage)%)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hexString: family.color).opacity(0.2), lineWidth: 1)
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
}

// MARK: - Preview
struct FamilyMapResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStats: [ChemicalFamily: (correct: Int, total: Int)] = [
            .noMetales: (correct: 2, total: 3),
            .metalesAlcalinos: (correct: 1, total: 2),
            .gasesNobles: (correct: 2, total: 2)
        ]
        
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color.purple.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            FamilyMapResultsView(
                correctCount: 8,
                incorrectCount: 2,
                totalTime: 125,
                difficulty: .medium,
                familyStats: sampleStats,
                onPlayAgain: {},
                onExit: {}
            )
        }
    }
}

