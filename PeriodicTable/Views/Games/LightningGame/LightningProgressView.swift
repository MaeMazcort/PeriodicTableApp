//
//  LightningProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Real-time progress with prominent timer
//

import SwiftUI

struct LightningProgressView: View {
    let timeRemaining: Int
    let correctCount: Int
    let incorrectCount: Int
    let currentStreak: Int
    let totalPoints: Int
    
    private let totalTime: Int = 60
    
    var progress: Double {
        1.0 - (Double(timeRemaining) / Double(totalTime))
    }
    
    var isLowTime: Bool {
        timeRemaining <= 10
    }
    
    private var timerGradient: LinearGradient {
        LinearGradient(
            colors: isLowTime
            ? [Color.red, Color.pink]
            : [Color.indigo, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Giant timer - Most prominent element
            VStack(spacing: 8) {
                // Timer icon
                ZStack {
                    Circle()
                        .stroke(
                            isLowTime
                            ? Color.red.opacity(0.3)
                            : Color.indigo.opacity(0.15),
                            lineWidth: 8
                        )
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            timerGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                    
                    VStack(spacing: 4) {
                        Text("\(timeRemaining)")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(timerGradient)
                            .contentTransition(.numericText())
                            .monospacedDigit()
                        
                        Text("segundos")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .scaleEffect(isLowTime ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6).repeatCount(isLowTime ? Int.max : 1, autoreverses: true), value: isLowTime)
            }
            
            // Stats row
            HStack(spacing: 12) {
                // Points
                statBadge(
                    icon: "star.fill",
                    value: "\(totalPoints)",
                    color: Color.yellow,
                    label: "Puntos"
                )
                
                // Correct
                statBadge(
                    icon: "checkmark.circle.fill",
                    value: "\(correctCount)",
                    color: Color.green,
                    label: "Correctas"
                )
                
                // Streak
                if currentStreak > 0 {
                    statBadge(
                        icon: "flame.fill",
                        value: "\(currentStreak)",
                        color: Color.red,
                        label: "Racha"
                    )
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isLowTime
                    ? Color.red.opacity(0.3)
                    : Color.white.opacity(0.3),
                    lineWidth: 1
                )
        }
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
    
    private func statBadge(icon: String, value: String, color: Color, label: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Countdown View
struct LightningCountdownView: View {
    let count: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Countdown number
            Text("\(count)")
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.indigo, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.2
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.5)) {
                scale = 0.8
                opacity = 0
            }
        }
    }
}

// MARK: - Preview
struct LightningProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.12),
                    Color.purple.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                LightningProgressView(
                    timeRemaining: 45,
                    correctCount: 12,
                    incorrectCount: 3,
                    currentStreak: 5,
                    totalPoints: 345
                )
                
                LightningProgressView(
                    timeRemaining: 8,
                    correctCount: 25,
                    incorrectCount: 7,
                    currentStreak: 0,
                    totalPoints: 782
                )
            }
            .padding()
        }
    }
}

