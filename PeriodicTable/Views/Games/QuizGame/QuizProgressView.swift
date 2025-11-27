//
//  QuizProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego.
//  Progress header for quiz game.
//

import SwiftUI

struct QuizProgressView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let correctCount: Int
    let incorrectCount: Int
    let elapsedTime: Int
    
    var body: some View {
        VStack(spacing: 14) {
            topRow
            bottomRow
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Subviews
    
    private var topRow: some View {
        HStack(spacing: 16) {
            questionCounter
            Spacer()
            timer
        }
    }
    
    private var bottomRow: some View {
        HStack(spacing: 12) {
            correctCounter
            incorrectCounter
            Spacer()
            
            if correctCount + incorrectCount > 0 {
                accuracyView
            }
        }
    }
    
    private var questionCounter: some View {
        HStack(spacing: 8) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("\(currentQuestion)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Text("/")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text("\(totalQuestions)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
    
    private var timer: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(formattedTime)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
    
    private var correctCounter: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hexString: "51cf66"))
            
            Text("\(correctCount)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hexString: "51cf66").opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color(hexString: "51cf66").opacity(0.3), lineWidth: 1)
        }
    }
    
    private var incorrectCounter: some View {
        HStack(spacing: 6) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hexString: "ff6b6b"))
            
            Text("\(incorrectCount)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hexString: "ff6b6b").opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color(hexString: "ff6b6b").opacity(0.3), lineWidth: 1)
        }
    }
    
    private var accuracyView: some View {
        HStack(spacing: 6) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hexString: "667eea"))
            
            Text("\(accuracy)%")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hexString: "667eea").opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color(hexString: "667eea").opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Computed Properties
    
    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var accuracy: Int {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Int(Double(correctCount) / Double(total) * 100)
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
        
        VStack(spacing: 20) {
            QuizProgressView(
                currentQuestion: 1,
                totalQuestions: 10,
                correctCount: 0,
                incorrectCount: 0,
                elapsedTime: 0
            )
            
            QuizProgressView(
                currentQuestion: 5,
                totalQuestions: 10,
                correctCount: 4,
                incorrectCount: 0,
                elapsedTime: 65
            )
            
            QuizProgressView(
                currentQuestion: 10,
                totalQuestions: 10,
                correctCount: 7,
                incorrectCount: 3,
                elapsedTime: 195
            )
        }
        .padding()
    }
}
