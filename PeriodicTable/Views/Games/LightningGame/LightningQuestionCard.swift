//
//  LightningQuestionCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Fast-paced question card for lightning game
//

import SwiftUI
import UIKit

struct LightningQuestionCard: View {
    let question: LightningQuestion
    let onAnswer: (String) -> Void
    let showFeedback: Bool
    let wasCorrect: Bool
    
    @State private var selectedAnswer: String?
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 28) {
            // Question text - Large and readable
            Text(question.questionText)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 24)
                .frame(minHeight: 100)
            
            // Answer options
            if question.isTrueFalse {
                trueFalseButtons
            } else if let options = question.options {
                multipleChoiceButtons(options)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    showFeedback
                    ? LinearGradient(
                        colors: [
                            (wasCorrect ? Color(red: 0.3176, green: 0.8118, blue: 0.4) : Color(red: 1.0, green: 0.4196, blue: 0.4196)).opacity(0.6),
                            (wasCorrect ? Color(red: 0.3176, green: 0.8118, blue: 0.4) : Color(red: 1.0, green: 0.4196, blue: 0.4196)).opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: showFeedback ? 3 : 2
                )
        }
        .shadow(
            color: showFeedback
            ? (wasCorrect ? Color(red: 0.3176, green: 0.8118, blue: 0.4) : Color(red: 1.0, green: 0.4196, blue: 0.4196)).opacity(0.3)
            : .black.opacity(0.12),
            radius: showFeedback ? 20 : 16,
            x: 0,
            y: 8
        )
        .scaleEffect(scale)
        .onChange(of: showFeedback) { newValue in
            if newValue {
                // Pulse feedback
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.05
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                    scale = 1.0
                }
            }
        }
    }
    
    // MARK: - True/False Buttons
    private var trueFalseButtons: some View {
        HStack(spacing: 16) {
            trueFalseButton(answer: "Verdadero", icon: "checkmark.circle.fill", color: Color(red: 0.3176, green: 0.8118, blue: 0.4))
            trueFalseButton(answer: "Falso", icon: "xmark.circle.fill", color: Color(red: 1.0, green: 0.4196, blue: 0.4196))
        }
        .padding(.horizontal, 20)
    }
    
    private func trueFalseButton(answer: String, icon: String, color: Color) -> some View {
        Button {
            if !showFeedback {
                selectedAnswer = answer
                generateHaptic(style: .medium)
                onAnswer(answer)
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(color)
                
                Text(answer)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        showFeedback && selectedAnswer == answer
                        ? (wasCorrect ? Color(red: 0.3176, green: 0.8118, blue: 0.4) : Color(red: 1.0, green: 0.4196, blue: 0.4196)).opacity(0.8)
                        : color.opacity(0.3),
                        lineWidth: showFeedback && selectedAnswer == answer ? 3 : 2
                    )
            }
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(showFeedback)
    }
    
    // MARK: - Multiple Choice Buttons
    private func multipleChoiceButtons(_ options: [String]) -> some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                multipleChoiceButton(option: option)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func multipleChoiceButton(option: String) -> some View {
        Button {
            if !showFeedback {
                selectedAnswer = option
                generateHaptic(style: .medium)
                onAnswer(option)
            }
        } label: {
            HStack {
                Text(option)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 64)
            .background(
                showFeedback && selectedAnswer == option
                ? (wasCorrect ? Color(red: 0.3176, green: 0.8118, blue: 0.4) : Color(red: 1.0, green: 0.4196, blue: 0.4196)).opacity(0.15)
                : Color(red: 0.4, green: 0.4941, blue: 0.9176).opacity(0.08),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        showFeedback && selectedAnswer == option
                        ? (wasCorrect ? Color(red: 0.3176, green: 0.8118, blue: 0.4) : Color(red: 1.0, green: 0.4196, blue: 0.4196)).opacity(0.6)
                        : Color(red: 0.4, green: 0.4941, blue: 0.9176).opacity(0.3),
                        lineWidth: showFeedback && selectedAnswer == option ? 3 : 2
                    )
            }
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(showFeedback)
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview("LightningQuestionCard") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.4941, blue: 0.9176).opacity(0.12),
                Color(red: 0.4627, green: 0.2941, blue: 0.6353).opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 30) {
            LightningQuestionCard(
                question: LightningQuestion(
                    questionText: "El símbolo de Hidrógeno es 'H'",
                    correctAnswer: "Verdadero",
                    options: nil,
                    questionType: .symbolTrue,
                    relatedElementId: 1
                ),
                onAnswer: { _ in },
                showFeedback: false,
                wasCorrect: false
            )

            LightningQuestionCard(
                question: LightningQuestion(
                    questionText: "¿Cuál es el símbolo de Oxígeno?",
                    correctAnswer: "O",
                    options: ["O", "Ox", "O2"],
                    questionType: .symbolMatch,
                    relatedElementId: 8
                ),
                onAnswer: { _ in },
                showFeedback: false,
                wasCorrect: false
            )
        }
        .padding()
    }
}
