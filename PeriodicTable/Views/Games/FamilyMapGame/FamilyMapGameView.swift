//
//  FamilyMapGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Main view for family classification game
//

import SwiftUI

struct FamilyMapGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = FamilyMapGameViewModel()
    @State private var showDifficultyPicker = true
    @State private var selectedDifficulty: FamilyMapDifficulty = .easy
    @State private var selectedMode: FamilyMapGameMode = .buttons
    
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
                        FamilyMapResultsView(
                            correctCount: viewModel.correctCount,
                            incorrectCount: viewModel.incorrectCount,
                            totalTime: viewModel.elapsedTime,
                            difficulty: viewModel.difficulty,
                            familyStats: viewModel.familyStats,
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
                            Image(systemName: "square.grid.3x3.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Mapa por Familias")
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
                
                Image(systemName: "square.grid.3x3.fill")
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
                Text("Mapa por Familias")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Clasifica elementos por su familia química")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Difficulty options
            VStack(spacing: 16) {
                ForEach(FamilyMapDifficulty.allCases) { difficulty in
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
    
    private func difficultyCard(_ difficulty: FamilyMapDifficulty) -> some View {
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
                    
                    Text("\(difficulty.elementCount) elementos · \(difficulty.timeEstimate)")
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
            viewModel.startNewGame(
                elementos: dataManager.elementos,
                difficulty: selectedDifficulty,
                mode: selectedMode
            )
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 0) {
            // Progress header
            FamilyMapProgressView(
                currentElement: viewModel.currentElementIndex + 1,
                totalElements: viewModel.elements.count,
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Current element card
                    if let element = viewModel.currentElement {
                        ElementFamilyCardView(
                            element: element,
                            isClassified: viewModel.showFeedback,
                            isCorrect: viewModel.lastClassificationCorrect
                        )
                        .frame(height: 300)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                    
                    // Family selection
                    if !viewModel.showFeedback {
                        VStack(spacing: 16) {
                            Text("Selecciona la familia química:")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.secondary)
                            
                            FamilySelectionView(
                                onSelect: { family in
                                    viewModel.classifyElement(as: family)
                                },
                                disabled: viewModel.showFeedback
                            )
                            .padding(.horizontal, 20)
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    // Skip button
                    if !viewModel.showFeedback {
                        Button {
                            generateHaptic(style: .light)
                            viewModel.skipElement()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Saltar elemento")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 32)
            }
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
    FamilyMapGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
