//
//  FlashcardGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Enhanced with better state management and animations
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State Enum
enum FlashcardGameState: Equatable {
    case playing
    case completed
}

// MARK: - Flashcard Data Structure
struct Flashcard: Identifiable, Equatable {
    let id: Int
    let question: String
    let answer: String
}

// MARK: - ViewModel
class FlashcardGameViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var currentIndex: Int = 0
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var isFlipped: Bool = false
    @Published var gameState: FlashcardGameState = .playing
    @Published var elapsedTime: Int = 0
    
    private var timer: Timer?
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Empty by default; use startNewGame to populate.
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Game Control
    func startNewGame(elementos: [Elemento]) {
        self.flashcards = elementos.map {
            Flashcard(id: $0.id, question: $0.nombreES, answer: $0.simbolo)
        }.shuffled()
        
        self.currentIndex = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.isFlipped = false
        self.gameState = .playing
        self.elapsedTime = 0
        
        startTimer()
    }
    
    func flipCard() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            isFlipped.toggle()
        }
    }
    
    func markAsKnown(progressManager: ProgressManager) {
        updateProgress(progressManager: progressManager, correct: true)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            correctCount += 1
        }
        
        nextCard()
    }
    
    func markAsUnknown(progressManager: ProgressManager) {
        updateProgress(progressManager: progressManager, correct: false)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            incorrectCount += 1
        }
        
        nextCard()
    }
    
    func goToPreviousCard() {
        if currentIndex > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentIndex -= 1
                isFlipped = false
            }
        }
    }
    
    // MARK: - Private Methods
    private func nextCard() {
        if currentIndex < flashcards.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentIndex += 1
                isFlipped = false
            }
        } else {
            endGame()
        }
    }
    
    private func endGame() {
        stopTimer()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            gameState = .completed
        }
    }
    
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
    
    func saveProgress(progressManager: ProgressManager) {
        // Save session data
        guard !flashcards.isEmpty else { return }
        
        let session = SesionJuego(
            tipoJuego: .flashcards,
            duracionSegundos: elapsedTime,
            respuestasCorrectas: correctCount,
            respuestasTotales: correctCount + incorrectCount,
            puntuacion: calculateScore()
        )
        
        progressManager.registrarSesionJuego(session)
    }
    
    private func updateProgress(progressManager: ProgressManager, correct: Bool) {
        guard currentIndex < flashcards.count else { return }
        
        let elementId = flashcards[currentIndex].id
        progressManager.registrarRespuesta(elementoID: elementId, correcta: correct)
    }
    
    private func calculateScore() -> Int {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        
        let accuracy = Double(correctCount) / Double(total)
        let timeBonus = max(0, 1000 - elapsedTime) // Bonus for speed
        
        return Int(accuracy * 1000) + timeBonus
    }
    
    // MARK: - Computed Properties
    var progress: Double {
        guard !flashcards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(flashcards.count)
    }
    
    var accuracy: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total) * 100
    }
    
    var canGoBack: Bool {
        return currentIndex > 0
    }
}

