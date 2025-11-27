//
//  GuessPropertyProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Progress display for guess property game
//

import SwiftUI

struct GuessPropertyProgressView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let totalScore: Int
    let elapsedTime: Int
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestion) / Double(totalQuestions)
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Pregunta \(currentQuestion) de \(totalQuestions)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 8)
            }
            
            // Stats row
            HStack(spacing: 12) {
                // Score
                statBadge(
                    icon: "star.fill",
                    value: "\(totalScore)",
                    label: "Puntos",
                    color: Color(hexString: "ffd43b")
                )
                
                // Time
                statBadge(
                    icon: "clock.fill",
                    value: formattedTime,
                    label: "Tiempo",
                    color: Color(hexString: "ffa94d")
                )
                
                // Progress
                statBadge(
                    icon: "chart.pie.fill",
                    value: "\(Int(progress * 100))%",
                    label: "Avance",
                    color: Color(hexString: "667eea")
                )
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
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Preview
struct GuessPropertyProgressView_Previews: PreviewProvider {
    static var previews: some View {
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
            
            VStack(spacing: 20) {
                GuessPropertyProgressView(
                    currentQuestion: 3,
                    totalQuestions: 10,
                    totalScore: 240,
                    elapsedTime: 85
                )
                
                GuessPropertyProgressView(
                    currentQuestion: 8,
                    totalQuestions: 10,
                    totalScore: 680,
                    elapsedTime: 245
                )
            }
            .padding()
        }
    }
}
