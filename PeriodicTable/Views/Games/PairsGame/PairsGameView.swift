//
//  PairsGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Main view for matching pairs game with card grid
//

import SwiftUI

struct PairsGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = PairsGameViewModel()
    @State private var showDifficultyPicker = true
    @State private var selectedDifficulty: PairsDifficulty = .easy
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            VStack(spacing: 0) {
                if viewModel.gameState == .setup || showDifficultyPicker {
                    difficultySelectionView
                } else if viewModel.gameState == .playing {
                    playingView
                } else if viewModel.gameState == .completed {
                    PairsResultsView(
                        matchedPairs: viewModel.matchedPairs,
                        totalMoves: viewModel.moves,
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
                        Image(systemName: "square.on.square.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Parejas")
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
                
                Image(systemName: "square.on.square.fill")
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
                Text("Juego de Parejas")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Encuentra los pares: símbolo y número")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Difficulty options
            VStack(spacing: 16) {
                ForEach(PairsDifficulty.allCases) { difficulty in
                    difficultyCard(difficulty)
                }
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
    
    private func difficultyCard(_ difficulty: PairsDifficulty) -> some View {
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
                    
                    Text("\(difficulty.pairCount) parejas · \(difficulty.pairCount * 2) tarjetas")
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
    
    private func startGame() {
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
            PairsProgressView(
                matchedPairs: viewModel.matchedPairs,
                totalPairs: viewModel.totalPairs,
                moves: viewModel.moves,
                elapsedTime: viewModel.elapsedTime
            )
            .padding(.top, 8)
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Instructions
                    if viewModel.moves == 0 {
                        instructionsView
                            .padding(.top, 16)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    // Card grid
                    cardGrid
                        .padding(.top, viewModel.moves == 0 ? 8 : 20)
                        .padding(.bottom, 32)
                }
            }
        }
    }
    
    private var instructionsView: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hexString: "ffa94d"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Encuentra las parejas")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Empareja cada símbolo con su número atómico")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hexString: "ffa94d").opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal, 20)
    }
    
    private var cardGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.difficulty.gridColumns)
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.cards) { card in
                PairsCardView(card: card) {
                    viewModel.flipCard(card)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: viewModel.cards.map { $0.isFlipped })
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
    PairsGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
