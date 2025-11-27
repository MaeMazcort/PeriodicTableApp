//
//  QuizQuestionCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego on 26/11/25.
//


//
//  QuizQuestionCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Modern question card with interactive options
//

import SwiftUI

struct QuizQuestionCard: View {
    let question: QuizQuestion
    let selectedAnswer: String?
    let answerState: AnswerState
    let onSelectAnswer: (String) -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 28) {
            // Question text
            VStack(spacing: 16) {
                // Question type badge
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(questionTypeName)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                
                // Question
                Text(question.questionText)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.element) { index, option in
                    answerOption(option, index: index)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                }
            }
            
            // Feedback message
            if answerState != .notAnswered {
                feedbackView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                animateIn = true
            }
        }
        .onChange(of: question.id) { _, _ in
            animateIn = false
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Answer Option Styling Helpers
    
    private enum OptionState {
        case normal, selected, correct, incorrect
    }
    
    private struct OptionStyle {
        let circleFill: Color
        let letterColor: Color
        let overlayStroke: Color
        let overlayWidth: CGFloat
        let shadowColor: Color
        let shadowRadius: CGFloat
        
        init(state: OptionState) {
            switch state {
            case .normal:
                circleFill = Color.gray.opacity(0.1)
                letterColor = .secondary
                overlayStroke = Color.white.opacity(0.2)
                overlayWidth = 1
                shadowColor = .black.opacity(0.05)
                shadowRadius = 8
            case .selected:
                circleFill = Color(hex: "667eea").opacity(0.2)
                letterColor = Color(hex: "667eea")
                overlayStroke = Color(hex: "667eea").opacity(0.3)
                overlayWidth = 1
                shadowColor = .black.opacity(0.05)
                shadowRadius = 8
            case .correct:
                circleFill = Color(hex: "51cf66").opacity(0.2)
                letterColor = Color(hex: "51cf66")
                overlayStroke = Color(hex: "51cf66").opacity(0.5)
                overlayWidth = 2
                shadowColor = Color(hex: "51cf66").opacity(0.2)
                shadowRadius = 12
            case .incorrect:
                circleFill = Color(hex: "ff6b6b").opacity(0.2)
                letterColor = Color(hex: "ff6b6b")
                overlayStroke = Color(hex: "ff6b6b").opacity(0.5)
                overlayWidth = 2
                shadowColor = Color(hex: "ff6b6b").opacity(0.2)
                shadowRadius = 12
            }
        }
    }
    
    @ViewBuilder
    private func optionBackground(for state: OptionState) -> some View {
        switch state {
        case .correct:
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "51cf66").opacity(0.1))
        case .incorrect:
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "ff6b6b").opacity(0.1))
        case .selected:
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "667eea").opacity(0.08))
        case .normal:
            RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    private func statusIcon(for state: OptionState) -> some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color(hex: "51cf66"))
                .transition(.scale.combined(with: .opacity))
        case .incorrect:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color(hex: "ff6b6b"))
                .transition(.scale.combined(with: .opacity))
        case .normal, .selected:
            EmptyView()
        }
    }

    // MARK: - Answer Option View
    
    private func answerOption(_ option: String, index: Int) -> some View {
        let isSelected = selectedAnswer == option
        let isCorrect = option == question.correctAnswer
        
        let state: OptionState
        if answerState != .notAnswered && isCorrect {
            state = .correct
        } else if answerState == .incorrect && isSelected {
            state = .incorrect
        } else if isSelected && answerState == .notAnswered {
            state = .selected
        } else {
            state = .normal
        }
        
        let style = OptionStyle(state: state)
        
        return Button {
            if answerState == .notAnswered {
                generateHaptic(style: .light)
                onSelectAnswer(option)
            }
        } label: {
            HStack(spacing: 16) {
                // Option letter
                ZStack {
                    Circle()
                        .fill(style.circleFill)
                        .frame(width: 44, height: 44)
                    
                    Text(optionLetter(index))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(style.letterColor)
                }
                
                // Option text
                Text(option)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Status icon
                statusIcon(for: state)
            }
            .padding(18)
            .background(optionBackground(for: state))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(style.overlayStroke, lineWidth: style.overlayWidth)
            }
            .shadow(
                color: style.shadowColor,
                radius: style.shadowRadius,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .disabled(answerState != .notAnswered)
        .scaleEffect(state == .selected ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private var feedbackView: some View {
        HStack(spacing: 12) {
            Image(systemName: answerState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(answerState == .correct ? Color(hex: "51cf66") : Color(hex: "ff6b6b"))
            
            Text(answerState == .correct ? "¡Correcto!" : "Incorrecto")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
            
            if answerState == .incorrect {
                Spacer()
                
                Text("Respuesta: \(question.correctAnswer)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            answerState == .correct
            ? Color(hex: "51cf66").opacity(0.15)
            : Color(hex: "ff6b6b").opacity(0.15),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    answerState == .correct
                    ? Color(hex: "51cf66").opacity(0.3)
                    : Color(hex: "ff6b6b").opacity(0.3),
                    lineWidth: 1
                )
        }
    }
    
    private func optionLetter(_ index: Int) -> String {
        let letters = ["A", "B", "C", "D"]
        return letters[min(index, letters.count - 1)]
    }
    
    private var questionTypeName: String {
        switch question.questionType {
        case .symbolFromName: return "Símbolo"
        case .nameFromSymbol: return "Elemento"
        case .familyFromName: return "Familia"
        case .stateFromName: return "Estado"
        case .periodFromName: return "Periodo"
        case .groupFromName: return "Grupo"
        case .atomicNumberFromName: return "Número Atómico"
        case .nameFromAtomicNumber: return "Elemento"
        }
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    let sampleQuestion = QuizQuestion(
        questionText: "¿Cuál es el símbolo del Hidrógeno?",
        correctAnswer: "H",
        options: ["H", "He", "Li", "Be"],
        questionType: .symbolFromName,
        relatedElementId: 1
    )
    
    return ZStack {
        LinearGradient(
            colors: [
                Color(hex: "667eea").opacity(0.12),
                Color(hex: "764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            QuizQuestionCard(
                question: sampleQuestion,
                selectedAnswer: nil,
                answerState: .notAnswered,
                onSelectAnswer: { _ in }
            )
            .padding()
            
            QuizQuestionCard(
                question: sampleQuestion,
                selectedAnswer: "H",
                answerState: .correct,
                onSelectAnswer: { _ in }
            )
            .padding()
        }
    }
}
