//
//  QuizGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego on 26/11/25.
//


//
//  QuizGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Modern quiz game with dynamic questions and smooth animations
//

import SwiftUI

struct QuizGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = QuizGameViewModel()
    @State private var showDifficultyPicker = true
    @State private var selectedDifficulty: QuizDifficulty = .mixed
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    if viewModel.gameState == .setup || showDifficultyPicker {
                        difficultySelectionView
                    } else if viewModel.gameState == .playing {
                        playingView
                    } else if viewModel.gameState == .completed {
                        QuizResultsView(
                            correctCount: viewModel.correctCount,
                            incorrectCount: viewModel.incorrectCount,
                            totalTime: viewModel.elapsedTime,
                            difficulty: viewModel.difficulty,
                            onPlayAgain: {
                                withAnimation {
                                    showDifficultyPicker = true
                                    viewModel.gameState = .setup
                                }
                            },
                            onExit: {
                                dismiss()
                            }
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    exitButton
                }
                ToolbarItem(placement: .principal) {
                    if !showDifficultyPicker {
                        HStack(spacing: 6) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Quiz")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.12),
                Color(hexString: "764ba2").opacity(0.08),
                Color(hexString: "f093fb").opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Difficulty Selection
    private var difficultySelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hexString: "667eea").opacity(0.2), Color(hexString: "764ba2").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Title
            VStack(spacing: 12) {
                Text("Quiz de Elementos")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Selecciona la dificultad")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // Difficulty options
            VStack(spacing: 16) {
                ForEach(QuizDifficulty.allCases) { difficulty in
                    difficultyCard(difficulty)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Start button
            Button {
                startQuiz()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Comenzar Quiz")
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
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
    
    private func difficultyCard(_ difficulty: QuizDifficulty) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedDifficulty = difficulty
            }
            generateHaptic(style: .light)
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hexString: difficulty.color).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: difficulty.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hexString: difficulty.color))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("\(difficulty.questionCount) preguntas")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: selectedDifficulty == difficulty ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        selectedDifficulty == difficulty
                        ? Color(hexString: difficulty.color)
                        : Color.gray.opacity(0.3)
                    )
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        selectedDifficulty == difficulty
                        ? Color(hexString: difficulty.color).opacity(0.5)
                        : Color.clear,
                        lineWidth: 2
                    )
            }
            .shadow(
                color: selectedDifficulty == difficulty
                ? Color(hexString: difficulty.color).opacity(0.2)
                : .clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
    
    private func startQuiz() {
        generateHaptic(style: .medium)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            showDifficultyPicker = false
            viewModel.startNewGame(elementos: dataManager.elementos, difficulty: selectedDifficulty)
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 0) {
            // Progress header
            QuizProgressView(
                currentQuestion: viewModel.currentQuestionIndex + 1,
                totalQuestions: viewModel.questions.count,
                correctCount: viewModel.correctCount,
                incorrectCount: viewModel.incorrectCount,
                elapsedTime: viewModel.elapsedTime
            )
            .padding(.top, 8)
            .padding(.horizontal, 20)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.progress, height: 6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            Spacer()
            
            // Question card
            if let question = viewModel.currentQuestion {
                QuizQuestionCard(
                    question: question,
                    selectedAnswer: viewModel.selectedAnswer,
                    answerState: viewModel.answerState,
                    onSelectAnswer: { answer in
                        viewModel.selectAnswer(answer)
                    }
                )
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Navigation buttons
            navigationButtons
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            Button {
                generateHaptic(style: .light)
                viewModel.previousQuestion()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Anterior")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoBack)
            .opacity(viewModel.canGoBack ? 1 : 0.5)
            
            // Next button
            Button {
                generateHaptic(style: .medium)
                viewModel.nextQuestion()
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finalizar" : "Siguiente")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "checkmark" : "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: viewModel.canGoNext
                        ? [Color(hexString: "667eea"), Color(hexString: "764ba2")]
                        : [Color.gray, Color.gray],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .shadow(
                    color: viewModel.canGoNext ? Color(hexString: "667eea").opacity(0.4) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canGoNext)
        }
    }
    
    // MARK: - Exit Button
    private var exitButton: some View {
        Button {
            if viewModel.gameState == .playing {
                viewModel.saveProgress(progressManager: progressManager)
            }
            generateHaptic(style: .light)
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                
                Text("Salir")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    QuizGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
