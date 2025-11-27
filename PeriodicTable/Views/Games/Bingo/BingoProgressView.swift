//
//  BingoProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Progress stats and game controls
//

import SwiftUI

struct BingoProgressView: View {
    let markedCount: Int
    let totalCells: Int
    let elapsedTime: Int
    let patternsAchieved: [BingoWinPattern]
    let isPaused: Bool
    let isAutoMode: Bool
    let onTogglePause: () -> Void
    let onCallNext: () -> Void
    
    var progress: Double {
        guard totalCells > 0 else { return 0 }
        return Double(markedCount) / Double(totalCells)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso del Cartón")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(markedCount)/\(totalCells)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "667eea"))
                        .contentTransition(.numericText())
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 10)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 10)
            }
            
            // Stats row
            HStack(spacing: 12) {
                // Timer
                statBadge(
                    icon: "clock.fill",
                    value: formattedTime,
                    label: "Tiempo",
                    color: Color(hex: "ffa94d")
                )
                
                // Patterns achieved
                statBadge(
                    icon: "checkmark.seal.fill",
                    value: "\(patternsAchieved.count)",
                    label: "Patrones",
                    color: Color(hex: "51cf66")
                )
                
                // Progress percentage
                statBadge(
                    icon: "chart.pie.fill",
                    value: "\(Int(progress * 100))%",
                    label: "Completo",
                    color: Color(hex: "667eea")
                )
            }
            
            // Controls
            if isAutoMode {
                // Pause/Resume button
                Button {
                    generateHaptic(style: .medium)
                    onTogglePause()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(isPaused ? "Reanudar" : "Pausar")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        isPaused
                        ? Color(hex: "51cf66")
                        : Color(hex: "ffa94d"),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .shadow(
                        color: (isPaused ? Color(hex: "51cf66") : Color(hex: "ffa94d")).opacity(0.4),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                }
                .buttonStyle(.plain)
            } else {
                // Manual call button
                Button {
                    generateHaptic(style: .medium)
                    onCallNext()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Cantar Siguiente")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .monospacedDigit()
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
    
    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Patterns Display
struct BingoPatternsView: View {
    let patterns: [BingoWinPattern]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "ffd43b"))
                
                Text("Patrones Logrados")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            if patterns.isEmpty {
                Text("Aún no has completado ningún patrón")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(patterns, id: \.rawValue) { pattern in
                        patternRow(pattern)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func patternRow(_ pattern: BingoWinPattern) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "ffd43b").opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: pattern.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "ffd43b"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(pattern.shortName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("+\(pattern.points) puntos")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: "51cf66"))
        }
        .padding(12)
        .background(Color(hex: "ffd43b").opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "ffd43b").opacity(0.3), lineWidth: 1)
        }
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
        
        VStack(spacing: 20) {
            BingoProgressView(
                markedCount: 12,
                totalCells: 25,
                elapsedTime: 145,
                patternsAchieved: [.horizontal1, .vertical2],
                isPaused: false,
                isAutoMode: true,
                onTogglePause: {},
                onCallNext: {}
            )
            
            BingoPatternsView(
                patterns: [.horizontal1, .vertical2, .diagonal1]
            )
        }
        .padding()
    }
}
