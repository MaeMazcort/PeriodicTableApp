//
//  LightningGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Main view for 60-second lightning challenge
//

import SwiftUI

struct LightningGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = LightningGameViewModel()
    @State private var showInstructions = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    if showInstructions {
                        instructionsView
                    } else if case .countdown(let count) = viewModel.gameState {
                        LightningCountdownView(count: count)
                    } else if viewModel.gameState == .playing {
                        playingView
                    } else if viewModel.gameState == .completed {
                        LightningResultsView(
                            correctCount: viewModel.correctCount,
                            incorrectCount: viewModel.incorrectCount,
                            totalPoints: viewModel.totalPoints,
                            bestStreak: viewModel.bestStreak,
                            averageTime: viewModel.averageTimePerQuestion,
                            questionsPerMinute: viewModel.questionsPerMinute,
                            onPlayAgain: {
                                withAnimation {
                                    showInstructions = true
                                    viewModel.gameState = .ready
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
                    if showInstructions || viewModel.gameState == .completed {
                        exitButton
                    }
                }
                ToolbarItem(placement: .principal) {
                    if !showInstructions && viewModel.gameState != .completed {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Reto Relámpago")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
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
                Color(hex: "667eea").opacity(0.12),
                Color(hex: "764ba2").opacity(0.08),
                Color(hex: "f093fb").opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Instructions View
    private var instructionsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Lightning icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Title
            VStack(spacing: 12) {
                Text("Reto Relámpago")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Responde todo lo que puedas en 60 segundos")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Instructions cards
            VStack(spacing: 14) {
                instructionCard(
                    icon: "timer",
                    title: "60 Segundos",
                    description: "Tienes un minuto para responder",
                    color: Color(hex: "667eea")
                )
                
                instructionCard(
                    icon: "bolt.fill",
                    title: "Responde Rápido",
                    description: "Más rápido = más puntos",
                    color: Color(hex: "ffd43b")
                )
                
                instructionCard(
                    icon: "flame.fill",
                    title: "Mantén la Racha",
                    description: "Respuestas correctas seguidas dan bonus",
                    color: Color(hex: "ff6b6b")
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Start button
            Button {
                startGame()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("¡Comenzar Desafío!")
                        .font(.system(size: 19, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
    
    private func instructionCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 54, height: 54)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.25), lineWidth: 1.5)
        }
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func startGame() {
        generateHaptic(style: .medium)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            showInstructions = false
            viewModel.startGame(elementos: dataManager.elementos)
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 0) {
            // Progress header
            LightningProgressView(
                timeRemaining: viewModel.timeRemaining,
                correctCount: viewModel.correctCount,
                incorrectCount: viewModel.incorrectCount,
                currentStreak: viewModel.currentStreak,
                totalPoints: viewModel.totalPoints
            )
            .padding(.top, 8)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Question card
            if let question = viewModel.currentQuestion {
                LightningQuestionCard(
                    question: question,
                    onAnswer: { answer in
                        viewModel.answerQuestion(answer: answer)
                    },
                    showFeedback: viewModel.showFeedback,
                    wasCorrect: viewModel.lastAnswerCorrect
                )
                .padding(.horizontal, 20)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 1.05))
                ))
                .id(question.id)
            }
            
            Spacer()
            
            // Tips footer (only shown when not in feedback)
            if !viewModel.showFeedback {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "ffd43b"))
                    
                    Text(tipText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .transition(.opacity)
            }
        }
    }
    
    private var tipText: String {
        if viewModel.currentStreak >= 5 {
            return "¡Racha de \(viewModel.currentStreak)! Sigue así 🔥"
        } else if viewModel.timeRemaining <= 15 {
            return "¡Últimos segundos! Da todo 💪"
        } else {
            return "Responde rápido para más puntos ⚡"
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
    LightningGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
