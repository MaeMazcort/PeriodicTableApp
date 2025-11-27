//
//  BingoGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Main view for Bingo game
//

import SwiftUI

struct BingoGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = BingoGameViewModel()
    @State private var showSetup = true
    @State private var selectedMode: BingoGameMode = .auto
    @State private var selectedSpeed: BingoGameSpeed = .normal
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    if showSetup {
                        setupView
                    } else if viewModel.gameState == .playing {
                        playingView
                    } else if case .won(let patterns) = viewModel.gameState {
                        BingoResultsView(
                            patterns: patterns,
                            totalTime: viewModel.elapsedTime,
                            markedCount: viewModel.markedOnCard,
                            totalCalled: viewModel.totalElementsCalled,
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
                    if showSetup || viewModel.gameState != .playing {
                        exitButton
                    }
                }
                ToolbarItem(placement: .principal) {
                    if !showSetup {
                        HStack(spacing: 6) {
                            Image(systemName: "circle.grid.3x3.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Bingo Químico")
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
    
    // MARK: - Setup View
    private var setupView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea").opacity(0.2), Color(hex: "764ba2").opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 60, weight: .semibold))
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
                    Text("Bingo Químico")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Completa tu cartón de elementos")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Mode selection
                VStack(spacing: 14) {
                    Text("Modo de Juego")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    ForEach(BingoGameMode.allCases, id: \.rawValue) { mode in
                        modeCard(mode)
                    }
                }
                .padding(.horizontal, 20)
                
                // Speed selection (only for auto mode)
                if selectedMode == .auto {
                    VStack(spacing: 14) {
                        Text("Velocidad")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            ForEach(BingoGameSpeed.allCases) { speed in
                                speedChip(speed)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
                
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
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func modeCard(_ mode: BingoGameMode) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedMode = mode
            }
            generateHaptic(style: .light)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "667eea").opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: "667eea"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text(mode.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: selectedMode == mode ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        selectedMode == mode
                        ? Color(hex: "667eea")
                        : Color.gray.opacity(0.3)
                    )
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        selectedMode == mode
                        ? Color(hex: "667eea").opacity(0.5)
                        : Color.clear,
                        lineWidth: 2
                    )
            }
            .shadow(
                color: selectedMode == mode
                ? Color(hex: "667eea").opacity(0.2)
                : .clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(.plain)
    }
    
    private func speedChip(_ speed: BingoGameSpeed) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedSpeed = speed
            }
            generateHaptic(style: .light)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: speed.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(hex: speed.color))
                
                Text(speed.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                selectedSpeed == speed
                ? Color(hex: speed.color).opacity(0.15)
                : Color.gray.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedSpeed == speed
                        ? Color(hex: speed.color).opacity(0.5)
                        : Color.gray.opacity(0.2),
                        lineWidth: selectedSpeed == speed ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
    
    private func startGame() {
        generateHaptic(style: .medium)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            showSetup = false
            viewModel.startNewGame(
                elementos: dataManager.elementos,
                mode: selectedMode,
                speed: selectedSpeed
            )
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Called element display
                if let card = viewModel.card {
                    BingoCalledElementView(
                        element: viewModel.currentCalledElement,
                        totalCalled: viewModel.totalElementsCalled
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Progress and controls
                    BingoProgressView(
                        markedCount: viewModel.markedOnCard,
                        totalCells: card.totalCells,
                        elapsedTime: viewModel.elapsedTime,
                        patternsAchieved: viewModel.achievedPatterns,
                        isPaused: viewModel.isPaused,
                        isAutoMode: viewModel.gameMode == .auto,
                        onTogglePause: {
                            viewModel.togglePause()
                        },
                        onCallNext: {
                            viewModel.callNextElement()
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // Bingo card
                    BingoCardView(
                        card: card,
                        onCellTap: { elementId in
                            viewModel.toggleManualMark(id: elementId)
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // Patterns achieved
                    if !viewModel.achievedPatterns.isEmpty {
                        BingoPatternsView(patterns: viewModel.achievedPatterns)
                            .padding(.horizontal, 20)
                    }
                    
                    // Called elements history
                    if !viewModel.calledElements.isEmpty {
                        BingoCalledHistoryView(elements: viewModel.calledElements)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 32)
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
    BingoGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
