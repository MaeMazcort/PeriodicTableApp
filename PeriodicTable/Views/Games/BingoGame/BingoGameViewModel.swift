//
//  BingoGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Bingo game logic with auto/manual calling
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum BingoGameState: Equatable {
    case setup
    case playing
    case won([BingoWinPattern])  // Can win multiple patterns at once
}

// MARK: - ViewModel
class BingoGameViewModel: ObservableObject {
    @Published var card: BingoCard?
    @Published var calledElements: [Elemento] = []
    @Published var currentCalledElement: Elemento?
    @Published var remainingElements: [Elemento] = []
    @Published var gameState: BingoGameState = .setup
    @Published var gameMode: BingoGameMode = .auto
    @Published var gameSpeed: BingoGameSpeed = .normal
    @Published var elapsedTime: Int = 0
    @Published var isPaused: Bool = false
    @Published var achievedPatterns: [BingoWinPattern] = []
    
    private var callTimer: Timer?
    private var clockTimer: Timer?
    private var startTime: Date?
    
    var totalElementsCalled: Int {
        calledElements.count
    }
    
    var markedOnCard: Int {
        card?.markedCount ?? 0
    }
    
    var progressPercentage: Double {
        guard let card = card else { return 0 }
        return Double(markedOnCard) / Double(card.totalCells) * 100
    }
    
    init() {}
    
    deinit {
        stopTimers()
    }
    
    // MARK: - Game Setup
    func startNewGame(elementos: [Elemento], mode: BingoGameMode, speed: BingoGameSpeed) {
        self.gameMode = mode
        self.gameSpeed = speed
        
        // Create new bingo card
        self.card = BingoCard(elementos: elementos)
        
        // Shuffle all elements for calling
        self.remainingElements = elementos.shuffled()
        self.calledElements = []
        self.currentCalledElement = nil
        self.elapsedTime = 0
        self.isPaused = false
        self.achievedPatterns = []
        
        self.gameState = .playing
        startClockTimer()
        
        // Start auto-calling if auto mode
        if mode == .auto {
            startAutoCall()
        }
    }
    
    // MARK: - Calling Elements
    func callNextElement() {
        guard !remainingElements.isEmpty else { return }
        guard case .playing = gameState else { return }
        
        // Get next element
        let element = remainingElements.removeFirst()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            currentCalledElement = element
            calledElements.append(element)
        }
        
        // Check if element is on card and mark it
        if let card = card, card.hasElement(id: element.id) {
            markElement(id: element.id)
        }
        
        // Check for wins after marking
        checkForWins()
    }
    
    private func markElement(id: Int) {
        guard var card = card else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            card.markElement(id: id)
            self.card = card
        }
    }
    
    func toggleManualMark(id: Int) {
        // Only allow manual marking if element was called
        guard let element = calledElements.first(where: { $0.id == id }) else { return }
        markElement(id: id)
        checkForWins()
    }
    
    // MARK: - Auto Calling
    private func startAutoCall() {
        callTimer?.invalidate()
        
        callTimer = Timer.scheduledTimer(withTimeInterval: gameSpeed.interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if !self.isPaused && self.gameState == .playing {
                    self.callNextElement()
                }
            }
        }
    }
    
    func togglePause() {
        withAnimation {
            isPaused.toggle()
        }
    }
    
    // MARK: - Win Checking
    private func checkForWins() {
        guard let card = card else { return }
        
        let wins = card.checkForWins()
        
        if !wins.isEmpty {
            // New wins achieved
            let newWins = wins.filter { !achievedPatterns.contains($0) }
            
            if !newWins.isEmpty {
                achievedPatterns.append(contentsOf: newWins)
                
                // Check if BINGO (full card)
                if newWins.contains(.fullCard) {
                    endGame(with: wins)
                }
            }
        }
    }
    
    private func endGame(with patterns: [BingoWinPattern]) {
        stopTimers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                self.gameState = .won(patterns)
            }
        }
    }
    
    // MARK: - Timers
    private func startClockTimer() {
        startTime = Date()
        clockTimer?.invalidate()
        
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            
            DispatchQueue.main.async {
                if !self.isPaused {
                    self.elapsedTime = Int(Date().timeIntervalSince(start))
                }
            }
        }
    }
    
    private func stopTimers() {
        callTimer?.invalidate()
        callTimer = nil
        clockTimer?.invalidate()
        clockTimer = nil
    }
    
    // MARK: - Progress Tracking
    func saveProgress(progressManager: ProgressManager) {
        guard let card = card else { return }
        
        let totalPoints = achievedPatterns.reduce(0) { $0 + $1.points }
        
        let session = SesionJuego(
            tipoJuego: .bingo,
            duracionSegundos: elapsedTime,
            respuestasCorrectas: markedOnCard,
            respuestasTotales: card.totalCells,
            puntuacion: totalPoints
        )
        
        progressManager.registrarSesionJuego(session)
        
        // Register marked elements
        let allCells = card.cells.flatMap { $0 }
        for cell in allCells where cell.isMarked {
            progressManager.registrarRespuesta(elementoID: cell.id, correcta: true)
        }
    }
    
    // MARK: - Computed Properties
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var totalPoints: Int {
        achievedPatterns.reduce(0) { $0 + $1.points }
    }
}
