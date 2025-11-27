//
//  FlashcardGameView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Enhanced with modern UX, swipe gestures, and smooth animations
//

import SwiftUI
import Combine

struct FlashcardGameView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject private var ttsManager: TTSManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: FlashcardGameViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var showConfetti: Bool = false
    @State private var cardRotation: Double = 0
    @State private var showHint: Bool = true
    
    init() {
        _viewModel = StateObject(wrappedValue: FlashcardGameViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Compact progress header
                    progressHeader
                        .padding(.top, 8)
                    
                    if viewModel.gameState == .playing {
                        playingView
                    } else if viewModel.gameState == .completed {
                        resultsView
                    }
                }
                
                // Confetti overlay for celebrations
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    exitButton
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Flashcards")
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
            .onAppear {
                if viewModel.flashcards.isEmpty {
                    viewModel.startNewGame(elementos: dataManager.elementos)
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                    showHint = true
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
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        HStack(spacing: 16) {
            // Progress indicator with animation
            HStack(spacing: 8) {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("\(viewModel.currentIndex + 1)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                Text("/")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text("\(viewModel.flashcards.count)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            Spacer()
            
            // Score indicators with pulse animation
            HStack(spacing: 12) {
                scoreIndicator(
                    icon: "checkmark.circle.fill",
                    count: viewModel.correctCount,
                    color: Color(hex: "51cf66")
                )
                
                scoreIndicator(
                    icon: "xmark.circle.fill",
                    count: viewModel.incorrectCount,
                    color: Color(hex: "ff6b6b")
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    private func scoreIndicator(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
            
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated progress bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 6)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth, height: 6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentIndex)
            }
            .padding(.horizontal, 40)
            
            // Flashcard with swipe gestures
            flashcardStack
            
            // Dynamic hint text
            VStack(spacing: 8) {
                if !viewModel.isFlipped {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 13, weight: .medium))
                        Text("Toca para voltear")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .opacity(showHint ? 0.6 : 0.3)
                    .animation(.easeInOut(duration: 1.5).repeatForever(), value: showHint)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 13, weight: .medium))
                        Text("Desliza o usa los botones")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .opacity(0.6)
                }
            }
            .padding(.top, 8)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            
            Spacer()
            
            // Action buttons (shown after flip)
            if viewModel.isFlipped {
                actionButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // Spacer to maintain layout
                Color.clear
                    .frame(height: 100)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: viewModel.isFlipped)
    }
    
    private var progressWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 80
        let progress = CGFloat(viewModel.currentIndex) / CGFloat(max(viewModel.flashcards.count - 1, 1))
        return screenWidth * progress
    }
    
    // MARK: - Flashcard Stack
    private var flashcardStack: some View {
        ZStack {
            // Background cards for depth effect
            ForEach(0..<min(3, viewModel.flashcards.count - viewModel.currentIndex), id: \.self) { index in
                if viewModel.currentIndex + index < viewModel.flashcards.count {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        .scaleEffect(1 - (CGFloat(index) * 0.04))
                        .offset(y: CGFloat(index) * 10)
                        .opacity(1 - (Double(index) * 0.25))
                        .zIndex(-Double(index))
                }
            }
            
            // Main flashcard
            if viewModel.currentIndex < viewModel.flashcards.count {
                mainFlashcard
            }
        }
        .frame(height: 420)
        .padding(.horizontal, 24)
    }
    
    private var mainFlashcard: some View {
        let flashcard = viewModel.flashcards[viewModel.currentIndex]
        let swipeThreshold: CGFloat = 100
        let swipeProgress = min(abs(dragOffset.width) / swipeThreshold, 1.0)
        
        return ZStack {
            // Card background with gradient border
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 12)
            
            // Swipe indicators
            if viewModel.isFlipped && abs(dragOffset.width) > 20 {
                swipeIndicators(swipeProgress: swipeProgress)
            }
            
            // Content: two faces
            ZStack {
                // Front face
                VStack(spacing: 24) {
                    // Front side - Question
                    VStack(spacing: 20) {
                        // Animated icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "667eea").opacity(0.2),
                                            Color(hex: "764ba2").opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: "atom")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        // Question text
                        Text(flashcard.question)
                            .font(.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.7)
                            .lineLimit(2)
                        
                        Text("¿Cuál es el símbolo?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        // TTS button for element name (front side)
                        Button {
                            ttsManager.speak(flashcard.question)
                            generateHaptic(style: .light)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Escuchar pronunciación")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(Color(hex: "667eea"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(hex: "667eea").opacity(0.1), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 28)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.vertical, 24)
                .opacity(viewModel.isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(viewModel.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                
                // Back face
                VStack(spacing: 24) {
                    // Back side - Answer
                    VStack(spacing: 20) {
                        // Answer badge
                        Text("SÍMBOLO")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                        
                        // Answer text with special styling
                        Text(flashcard.answer)
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Element name reference
                        Text(flashcard.question)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 28)
                    
                    // TTS button
                    Button {
                        ttsManager.speak(flashcard.answer)
                        generateHaptic(style: .light)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Escuchar pronunciación")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(Color(hex: "667eea"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: "667eea").opacity(0.1), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.vertical, 24)
                .opacity(viewModel.isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(viewModel.isFlipped ? 360 : 180), axis: (x: 0, y: 1, z: 0))
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: viewModel.isFlipped)
        }
        .offset(x: dragOffset.width, y: dragOffset.height * 0.3)
        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if viewModel.isFlipped {
                        dragOffset = value.translation
                        rotationAngle = Double(value.translation.width / 10)
                    }
                }
                .onEnded { value in
                    if viewModel.isFlipped {
                        handleSwipeEnd(translation: value.translation.width)
                    }
                }
        )
        .onTapGesture {
            flipCard()
        }
    }
    
    private func swipeIndicators(swipeProgress: CGFloat) -> some View {
        HStack {
            // Left indicator (Don't know)
            if dragOffset.width < -20 {
                VStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color(hex: "ff6b6b"))
                    Text("No lo sé")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "ff6b6b"))
                }
                .opacity(swipeProgress)
                .scaleEffect(0.8 + (swipeProgress * 0.2))
                .padding(.leading, 32)
            }
            
            Spacer()
            
            // Right indicator (Know)
            if dragOffset.width > 20 {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color(hex: "51cf66"))
                    Text("Lo sé")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "51cf66"))
                }
                .opacity(swipeProgress)
                .scaleEffect(0.8 + (swipeProgress * 0.2))
                .padding(.trailing, 32)
            }
        }
    }
    
    private func handleSwipeEnd(translation: CGFloat) {
        let threshold: CGFloat = 100
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if translation > threshold {
                // Swiped right - Know
                dragOffset = CGSize(width: 500, height: 0)
                generateHaptic(style: .soft)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.markAsKnown(progressManager: progressManager)
                    resetCardPosition()
                }
            } else if translation < -threshold {
                // Swiped left - Don't know
                dragOffset = CGSize(width: -500, height: 0)
                generateHaptic(style: .rigid)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.markAsUnknown(progressManager: progressManager)
                    resetCardPosition()
                }
            } else {
                // Return to center
                resetCardPosition()
            }
        }
    }
    
    private func resetCardPosition() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            dragOffset = .zero
            rotationAngle = 0
        }
    }
    
    private func flipCard() {
        generateHaptic(style: .light)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cardRotation += 180
        }
        
        // Delay the flip state change to sync with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            viewModel.flipCard()
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Don't know button
            Button {
                generateHaptic(style: .rigid)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    dragOffset = CGSize(width: -500, height: 0)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.markAsUnknown(progressManager: progressManager)
                    resetCardPosition()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("No lo sé")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "ff6b6b"), Color(hex: "ee5a52")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .shadow(color: Color(hex: "ff6b6b").opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            
            // Know button
            Button {
                generateHaptic(style: .soft)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    dragOffset = CGSize(width: 500, height: 0)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.markAsKnown(progressManager: progressManager)
                    resetCardPosition()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Lo sé")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "51cf66"), Color(hex: "37b24d")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .shadow(color: Color(hex: "51cf66").opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    // MARK: - Results View
    private var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated completion icon
            ZStack {
                // Pulsing background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 20, x: 0, y: 10)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.white)
            }
            .onAppear {
                showConfetti = true
                generateHaptic(style: .soft)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                }
            }
            
            // Title
            VStack(spacing: 8) {
                Text("¡Completado!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Has terminado todas las tarjetas")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // Stats cards
            HStack(spacing: 16) {
                statCard(
                    title: "Correctas",
                    value: "\(viewModel.correctCount)",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "51cf66")
                )
                
                statCard(
                    title: "Incorrectas",
                    value: "\(viewModel.incorrectCount)",
                    icon: "xmark.circle.fill",
                    color: Color(hex: "ff6b6b")
                )
            }
            .padding(.horizontal, 20)
            
            // Accuracy percentage
            let accuracy = viewModel.flashcards.isEmpty ? 0 : Double(viewModel.correctCount) / Double(viewModel.flashcards.count) * 100
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: "667eea"))
                    
                    Text("Precisión: \(Int(accuracy))%")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    
                    Text("Tiempo: \(formatTime(viewModel.elapsedTime))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button {
                    generateHaptic(style: .light)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        viewModel.startNewGame(elementos: dataManager.elementos)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Jugar de nuevo")
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
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                
                Button {
                    generateHaptic(style: .light)
                    dismiss()
                } label: {
                    Text("Salir")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.25), lineWidth: 1.5)
        }
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Exit Button
    private var exitButton: some View {
        Button {
            if viewModel.currentIndex > 0 {
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
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

#Preview {
    FlashcardGameView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
