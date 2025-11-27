//
//  FamilyMapGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Game logic for family classification
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum FamilyMapGameState: Equatable {
    case setup
    case playing
    case completed
}

// MARK: - ViewModel
class FamilyMapGameViewModel: ObservableObject {
    @Published var elements: [FamilyMapGameElement] = []
    @Published var currentElementIndex: Int = 0
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var gameState: FamilyMapGameState = .setup
    @Published var elapsedTime: Int = 0
    @Published var difficulty: FamilyMapDifficulty = .easy
    @Published var gameMode: FamilyMapGameMode = .buttons
    @Published var showFeedback: Bool = false
    @Published var lastClassificationCorrect: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    
    var currentElement: FamilyMapGameElement? {
        guard currentElementIndex < elements.count else { return nil }
        return elements[currentElementIndex]
    }
    
    var progress: Double {
        guard !elements.isEmpty else { return 0 }
        return Double(currentElementIndex) / Double(elements.count)
    }
    
    var classifiedCount: Int {
        correctCount + incorrectCount
    }
    
    init() {}
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Game Control
    func startNewGame(elementos: [Elemento], difficulty: FamilyMapDifficulty, mode: FamilyMapGameMode) {
        self.difficulty = difficulty
        self.gameMode = mode
        
        // Select random elements
        let selectedElements = elementos.shuffled().prefix(difficulty.elementCount)
        self.elements = selectedElements.map { FamilyMapGameElement(from: $0) }
        
        self.currentElementIndex = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.elapsedTime = 0
        self.showFeedback = false
        self.gameState = .playing
        
        startTimer()
    }
    
    func classifyElement(as family: ChemicalFamily) {
        guard currentElementIndex < elements.count else { return }
        
        // Mark element as classified
        elements[currentElementIndex].isClassified = true
        elements[currentElementIndex].classifiedAs = family
        
        // Check if correct
        let isCorrect = elements[currentElementIndex].isCorrect
        lastClassificationCorrect = isCorrect
        
        if isCorrect {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                correctCount += 1
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                incorrectCount += 1
            }
        }
        
        // Show feedback
        withAnimation {
            showFeedback = true
        }
        
        // Move to next element after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextElement()
        }
    }
    
    private func nextElement() {
        showFeedback = false
        
        if currentElementIndex < elements.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentElementIndex += 1
            }
        } else {
            endGame()
        }
    }
    
    func skipElement() {
        // Mark as incorrect skip
        if currentElementIndex < elements.count {
            elements[currentElementIndex].isClassified = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                incorrectCount += 1
            }
        }
        
        if currentElementIndex < elements.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentElementIndex += 1
            }
        } else {
            endGame()
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
        guard !elements.isEmpty else { return }
        
        let session = SesionJuego(
            tipoJuego: .mapaPorFamilias,
            duracionSegundos: elapsedTime,
            respuestasCorrectas: correctCount,
            respuestasTotales: elements.count,
            puntuacion: calculateScore()
        )
        
        progressManager.registrarSesionJuego(session)
        
        // Update progress for each element
        for element in elements where element.isClassified {
            progressManager.registrarRespuesta(
                elementoID: element.id,
                correcta: element.isCorrect
            )
        }
    }
    
    private func calculateScore() -> Int {
        guard elements.count > 0 else { return 0 }
        
        let accuracy = Double(correctCount) / Double(elements.count)
        let baseScore = Int(accuracy * 1000)
        
        // Time bonus (faster = better)
        let avgTimePerElement = Double(elapsedTime) / Double(elements.count)
        let timeBonus = max(0, Int((10 - avgTimePerElement) * 50))
        
        // Difficulty multiplier
        let difficultyMultiplier: Double
        switch difficulty {
        case .easy: difficultyMultiplier = 1.0
        case .medium: difficultyMultiplier = 1.5
        case .hard: difficultyMultiplier = 2.0
        }
        
        return Int(Double(baseScore + timeBonus) * difficultyMultiplier)
    }
    
    // MARK: - Computed Properties
    var accuracy: Double {
        guard elements.count > 0 else { return 0 }
        return Double(correctCount) / Double(elements.count) * 100
    }
    
    var familyStats: [ChemicalFamily: (correct: Int, total: Int)] {
        var stats: [ChemicalFamily: (correct: Int, total: Int)] = [:]
        
        for element in elements where element.isClassified {
            let family = element.correctFamily
            let current = stats[family] ?? (correct: 0, total: 0)
            stats[family] = (
                correct: current.correct + (element.isCorrect ? 1 : 0),
                total: current.total + 1
            )
        }
        
        return stats
    }
}
