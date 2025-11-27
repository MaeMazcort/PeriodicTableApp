//
//  PairsGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Game logic for matching pairs game
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum PairsGameState: Equatable {
    case setup
    case playing
    case completed
}

// MARK: - ViewModel
class PairsGameViewModel: ObservableObject {
    @Published var cards: [PairsCard] = []
    @Published var flippedCards: [PairsCard] = []
    @Published var matchedPairs: Int = 0
    @Published var moves: Int = 0
    @Published var gameState: PairsGameState = .setup
    @Published var elapsedTime: Int = 0
    @Published var difficulty: PairsDifficulty = .easy
    @Published var isProcessing: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    
    var totalPairs: Int {
        difficulty.pairCount
    }
    
    var progress: Double {
        guard totalPairs > 0 else { return 0 }
        return Double(matchedPairs) / Double(totalPairs)
    }
    
    init() {}
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Game Control
    func startNewGame(elementos: [Elemento], difficulty: PairsDifficulty) {
        self.difficulty = difficulty
        self.cards = PairsCardGenerator.generateCards(from: elementos, difficulty: difficulty)
        self.flippedCards = []
        self.matchedPairs = 0
        self.moves = 0
        self.elapsedTime = 0
        self.gameState = .playing
        self.isProcessing = false
        
        startTimer()
    }
    
    func flipCard(_ card: PairsCard) {
        // Don't allow flipping if processing, already matched, or already flipped
        guard !isProcessing,
              !card.isMatched,
              !flippedCards.contains(where: { $0.id == card.id }),
              let index = cards.firstIndex(where: { $0.id == card.id })
        else { return }
        
        // Flip the card
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            cards[index].isFlipped = true
        }
        
        flippedCards.append(cards[index])
        
        // Check if we have two flipped cards
        if flippedCards.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        guard flippedCards.count == 2 else { return }
        
        isProcessing = true
        moves += 1
        
        let card1 = flippedCards[0]
        let card2 = flippedCards[1]
        
        if card1.matches(card2) {
            // Match found!
            handleMatch(card1: card1, card2: card2)
        } else {
            // No match
            handleMismatch(card1: card1, card2: card2)
        }
    }
    
    private func handleMatch(card1: PairsCard, card2: PairsCard) {
        // Mark cards as matched after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                if let index1 = self.cards.firstIndex(where: { $0.id == card1.id }) {
                    self.cards[index1].isMatched = true
                }
                if let index2 = self.cards.firstIndex(where: { $0.id == card2.id }) {
                    self.cards[index2].isMatched = true
                }
                
                self.matchedPairs += 1
            }
            
            self.flippedCards.removeAll()
            self.isProcessing = false
            
            // Check if game is complete
            if self.matchedPairs == self.totalPairs {
                self.endGame()
            }
        }
    }
    
    private func handleMismatch(card1: PairsCard, card2: PairsCard) {
        // Flip cards back after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                if let index1 = self.cards.firstIndex(where: { $0.id == card1.id }) {
                    self.cards[index1].isFlipped = false
                }
                if let index2 = self.cards.firstIndex(where: { $0.id == card2.id }) {
                    self.cards[index2].isFlipped = false
                }
            }
            
            self.flippedCards.removeAll()
            self.isProcessing = false
        }
    }
    
    private func endGame() {
        stopTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                self.gameState = .completed
            }
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        startTime = Date()
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            
            DispatchQueue.main.async {
                self.elapsedTime = Int(Date().timeIntervalSince(start))
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Progress Tracking
    func saveProgress(progressManager: ProgressManager) {
        guard !cards.isEmpty else { return }
        
        let session = SesionJuego(
            tipoJuego: .parejas,
            duracionSegundos: elapsedTime,
            respuestasCorrectas: matchedPairs,
            respuestasTotales: totalPairs,
            puntuacion: calculateScore()
        )
        
        progressManager.registrarSesionJuego(session)
        
        // Update progress for matched elements
        for card in cards where card.isMatched {
            progressManager.registrarRespuesta(elementoID: card.elementId, correcta: true)
        }
    }
    
    private func calculateScore() -> Int {
        guard totalPairs > 0 else { return 0 }
        
        // Base score from completion
        let baseScore = 1000
        
        // Efficiency bonus (fewer moves = better)
        let perfectMoves = totalPairs // Minimum possible moves
        let efficiency = Double(perfectMoves) / Double(max(moves, perfectMoves))
        let efficiencyBonus = Int(efficiency * 500)
        
        // Time bonus (faster = better)
        let timeBonus = max(0, 300 - elapsedTime)
        
        // Difficulty multiplier
        let difficultyMultiplier: Double
        switch difficulty {
        case .easy: difficultyMultiplier = 1.0
        case .medium: difficultyMultiplier = 1.5
        case .hard: difficultyMultiplier = 2.0
        }
        
        return Int(Double(baseScore + efficiencyBonus + timeBonus) * difficultyMultiplier)
    }
    
    // MARK: - Computed Properties
    var accuracy: Double {
        guard moves > 0 else { return 0 }
        return Double(matchedPairs * 2) / Double(moves * 2) * 100
    }
    
    var efficiency: Double {
        guard totalPairs > 0, moves > 0 else { return 0 }
        let perfectMoves = totalPairs
        return min(Double(perfectMoves) / Double(moves) * 100, 100)
    }
}
