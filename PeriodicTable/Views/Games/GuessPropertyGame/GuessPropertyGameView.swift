//
//  GuessPropertyGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego on 27/11/25.
//


//
//  GuessPropertyGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Main view for property guessing game
//

import SwiftUI

struct GuessPropertyGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = GuessPropertyGameViewModel()
    @State private var showSetup = true
    @State private var selectedDifficulty: GuessPropertyDifficulty = .easy
    @State private var currentGuess: Double = 50.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    if showSetup {
                        setupView
                    } else if viewModel.gameState == .playing || viewModel.gameState == .reviewing {
                        playingView
                    } else if viewModel.gameState == .completed {
                        GuessPropertyResultsView(
                            totalScore: viewModel.totalScore,
                            averageScore: viewModel.averageScore,
                            averageError: viewModel.averageError,
                            totalTime: viewModel.elapsedTime,
                            excellentCount: viewModel.excellentCount,
                            goodCount: viewModel.goodCount,
                            okCount: viewModel.okCount,
                            fairCount: viewModel.fairCount,
                            poorCount: viewModel.poorCount,
                            propertyStats: viewModel.propertyStats,
                            difficulty: viewModel.difficulty,
                            onPlayAgain: {
                                withAnimation {
                                    showSetup = true
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
                    if showSetup || viewModel.gameState == .completed {
                        exitButton
                    }
                }
                ToolbarItem(placement: .principal) {
                    if !showSetup {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Adivina Propiedad")
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
    
    // MARK: - Setup View
    private var setupView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
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
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 60, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 12) {
                    Text("Adivina Propiedad")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Estima propiedades de los elementos")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 14) {
                    Text("Dificultad")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    ForEach(GuessPropertyDifficulty.allCases) { difficulty in
                        difficultyCard(difficulty)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button {
                    startGame()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Comenzar Juego")
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
    }
    
    private func difficultyCard(_ difficulty: GuessPropertyDifficulty) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedDifficulty = difficulty
            }
            generateHaptic(style: .light)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hexString: difficulty.color).opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: difficulty.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hexString: difficulty.color))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(difficulty.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
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
    
    private func startGame() {
        generateHaptic(style: .medium)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            showSetup = false
            viewModel.startNewGame(elementos: dataManager.elementos, difficulty: selectedDifficulty)
            
            // Initialize guess to middle of range
            if let question = viewModel.currentQuestion {
                currentGuess = (question.propertyType.minValue + question.propertyType.maxValue) / 2
            }
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        ScrollView {
            VStack(spacing: 20) {
                GuessPropertyProgressView(
                    currentQuestion: viewModel.currentQuestionIndex + 1,
                    totalQuestions: viewModel.questions.count,
                    totalScore: viewModel.totalScore,
                    elapsedTime: viewModel.elapsedTime
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                if let question = viewModel.currentQuestion {
                    if viewModel.showingAnswer {
                        GuessPropertyAnswerView(
                            question: question,
                            onNext: {
                                viewModel.nextQuestion()
                                if let nextQuestion = viewModel.currentQuestion {
                                    currentGuess = (nextQuestion.propertyType.minValue + nextQuestion.propertyType.maxValue) / 2
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                    } else {
                        GuessPropertyQuestionCard(
                            question: question,
                            guessValue: $currentGuess,
                            onSubmit: {
                                viewModel.submitGuess(value: currentGuess)
                            },
                            isReviewing: viewModel.showingAnswer
                        )
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Exit Button
    private var exitButton: some View {
        Button {
            if viewModel.gameState == .playing || viewModel.gameState == .reviewing {
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
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    GuessPropertyGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
