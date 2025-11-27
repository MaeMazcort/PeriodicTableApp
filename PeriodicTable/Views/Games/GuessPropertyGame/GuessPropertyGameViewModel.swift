//
//  GuessPropertyGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Property guessing game logic
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum GuessPropertyGameState: Equatable {
    case setup
    case playing
    case reviewing  // Showing answer after guess
    case completed
}

// MARK: - ViewModel
class GuessPropertyGameViewModel: ObservableObject {
    @Published var questions: [GuessPropertyQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var gameState: GuessPropertyGameState = .setup
    @Published var difficulty: GuessPropertyDifficulty = .easy
    @Published var totalScore: Int = 0
    @Published var elapsedTime: Int = 0
    @Published var showingAnswer: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    
    var currentQuestion: GuessPropertyQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var answeredCount: Int {
        questions.filter { $0.isAnswered }.count
    }
    
    var averageScore: Double {
        guard !questions.isEmpty else { return 0 }
        let totalPoints = questions.reduce(0) { $0 + $1.calculateScore() }
        return Double(totalPoints) / Double(questions.count)
    }
    
    var averageError: Double {
        let answeredQuestions = questions.filter { $0.isAnswered }
        guard !answeredQuestions.isEmpty else { return 0 }
        
        let totalError = answeredQuestions.reduce(0.0) { $0 + $1.percentError }
        return totalError / Double(answeredQuestions.count)
    }
    
    init() {}
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Game Setup
    func startNewGame(elementos: [Elemento], difficulty: GuessPropertyDifficulty) {
        self.difficulty = difficulty
        
        // Select elements based on difficulty
        let selectedElements: [Elemento]
        switch difficulty {
        case .easy:
            // Common elements (H, O, C, N, Fe, Cu, Au, Ag, etc.)
            let commonIds = [1, 6, 7, 8, 11, 26, 29, 47, 79]
            selectedElements = elementos.filter { commonIds.contains($0.id) }.shuffled()
        case .medium:
            // Mix of common and less common
            selectedElements = elementos.shuffled()
        case .hard:
            // All elements, including rare ones
            selectedElements = elementos.shuffled()
        }
        
        // Generate questions
        var generatedQuestions: [GuessPropertyQuestion] = []
        let propertyTypes = PropertyType.allCases.shuffled()
        
        for i in 0..<difficulty.questionCount {
            let element = selectedElements[i % selectedElements.count]
            let propertyType = propertyTypes[i % propertyTypes.count]
            
            let question = GuessPropertyQuestion(elemento: element, propertyType: propertyType)
            generatedQuestions.append(question)
        }
        
        self.questions = generatedQuestions
        self.currentQuestionIndex = 0
        self.totalScore = 0
        self.elapsedTime = 0
        self.showingAnswer = false
        self.gameState = .playing
        
        startTimer()
    }
    
    // MARK: - Answer Submission
    func submitGuess(value: Double) {
        guard currentQuestionIndex < questions.count else { return }
        
        // Update question with guess
        questions[currentQuestionIndex].userGuess = value
        questions[currentQuestionIndex].isAnswered = true
        
        // Calculate and add score
        let score = questions[currentQuestionIndex].calculateScore()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            totalScore += score
        }
        
        // Show answer
        withAnimation {
            showingAnswer = true
            gameState = .reviewing
        }
    }
    
    func nextQuestion() {
        showingAnswer = false
        
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentQuestionIndex += 1
                gameState = .playing
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
        guard !questions.isEmpty else { return }
        
        let session = SesionJuego(
            tipoJuego: .adivinaPropiedad,
            duracionSegundos: elapsedTime,
            respuestasCorrectas: questions.filter { $0.accuracyLevel == .excellent || $0.accuracyLevel == .good }.count,
            respuestasTotales: questions.count,
            puntuacion: totalScore
        )
        
        progressManager.registrarSesionJuego(session)
        
        // Register elements as reviewed
        for question in questions where question.isAnswered {
            let isCorrect = question.accuracyLevel == .excellent || question.accuracyLevel == .good
            progressManager.registrarRespuesta(elementoID: question.elemento.id, correcta: isCorrect)
        }
    }
    
    // MARK: - Computed Properties
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var excellentCount: Int {
        questions.filter { $0.accuracyLevel == .excellent }.count
    }
    
    var goodCount: Int {
        questions.filter { $0.accuracyLevel == .good }.count
    }
    
    var okCount: Int {
        questions.filter { $0.accuracyLevel == .ok }.count
    }
    
    var fairCount: Int {
        questions.filter { $0.accuracyLevel == .fair }.count
    }
    
    var poorCount: Int {
        questions.filter { $0.accuracyLevel == .poor }.count
    }
    
    var propertyStats: [PropertyType: (totalError: Double, count: Int)] {
        var stats: [PropertyType: (totalError: Double, count: Int)] = [:]
        
        for question in questions where question.isAnswered {
            let property = question.propertyType
            let current = stats[property] ?? (totalError: 0, count: 0)
            stats[property] = (
                totalError: current.totalError + question.percentError,
                count: current.count + 1
            )
        }
        
        return stats
    }
}
