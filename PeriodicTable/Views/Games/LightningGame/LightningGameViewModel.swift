//
//  LightningGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  60-second lightning challenge logic
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum LightningGameState: Equatable {
    case ready
    case countdown(Int)  // 3, 2, 1...
    case playing
    case completed
}

// MARK: - Answer Result
struct AnswerResult {
    let isCorrect: Bool
    let pointsEarned: Int
    let timeToAnswer: Double
}

// MARK: - ViewModel
class LightningGameViewModel: ObservableObject {
    @Published var questions: [LightningQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var totalPoints: Int = 0
    @Published var gameState: LightningGameState = .ready
    @Published var timeRemaining: Int = 60
    @Published var showFeedback: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    
    private var gameTimer: Timer?
    private var questionStartTime: Date?
    private var answerTimes: [Double] = []
    
    private let gameDuration: Int = 60  // 60 seconds
    
    var currentQuestion: LightningQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var answeredCount: Int {
        correctCount + incorrectCount
    }
    
    var accuracy: Double {
        guard answeredCount > 0 else { return 0 }
        return Double(correctCount) / Double(answeredCount) * 100
    }
    
    var averageTimePerQuestion: Double {
        guard !answerTimes.isEmpty else { return 0 }
        return answerTimes.reduce(0, +) / Double(answerTimes.count)
    }
    
    var questionsPerMinute: Double {
        let elapsedTime = Double(gameDuration - timeRemaining)
        guard elapsedTime > 0 else { return 0 }
        return Double(answeredCount) / elapsedTime * 60
    }
    
    init() {}
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Game Control
    func startGame(elementos: [Elemento]) {
        // Generate many questions (user won't answer all in 60s)
        self.questions = LightningQuestionGenerator.generateQuestions(from: elementos, count: 100)
        
        self.currentQuestionIndex = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.currentStreak = 0
        self.bestStreak = 0
        self.totalPoints = 0
        self.timeRemaining = gameDuration
        self.answerTimes = []
        self.showFeedback = false
        
        // Start countdown
        startCountdown()
    }
    
    private func startCountdown() {
        var count = 3
        gameState = .countdown(count)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            count -= 1
            
            if count > 0 {
                self.gameState = .countdown(count)
            } else {
                timer.invalidate()
                self.startPlaying()
            }
        }
    }
    
    private func startPlaying() {
        gameState = .playing
        questionStartTime = Date()
        startTimer()
    }
    
    func answerQuestion(answer: String) {
        guard let question = currentQuestion,
              let startTime = questionStartTime else { return }
        
        let timeToAnswer = Date().timeIntervalSince(startTime)
        answerTimes.append(timeToAnswer)
        
        let isCorrect = answer == question.correctAnswer
        
        // Update stats
        if isCorrect {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                correctCount += 1
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            }
            
            // Calculate points with time bonus
            let points = calculatePoints(
                basePoints: question.basePoints,
                timeToAnswer: timeToAnswer,
                streak: currentStreak
            )
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                totalPoints += points
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                incorrectCount += 1
                currentStreak = 0
            }
        }
        
        // Show feedback briefly
        lastAnswerCorrect = isCorrect
        showFeedback = true
        
        // Quick feedback, then next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.nextQuestion()
        }
    }
    
    private func nextQuestion() {
        showFeedback = false
        
        if currentQuestionIndex < questions.count - 1 && timeRemaining > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentQuestionIndex += 1
            }
            questionStartTime = Date()
        } else if timeRemaining <= 0 {
            endGame()
        }
    }
    
    private func calculatePoints(basePoints: Int, timeToAnswer: Double, streak: Int) -> Int {
        // Base points
        var points = basePoints
        
        // Time bonus (faster = more points)
        if timeToAnswer < 2.0 {
            points += 10  // Very fast bonus
        } else if timeToAnswer < 4.0 {
            points += 5   // Fast bonus
        }
        
        // Streak multiplier
        if streak >= 10 {
            points = Int(Double(points) * 2.0)  // 2x for 10+ streak
        } else if streak >= 5 {
            points = Int(Double(points) * 1.5)  // 1.5x for 5+ streak
        }
        
        return points
    }
    
    private func endGame() {
        stopTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                self.gameState = .completed
            }
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
        }
    }
    
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    // MARK: - Progress Tracking
    func saveProgress(progressManager: ProgressManager) {
        guard !questions.isEmpty else { return }
        
        let session = SesionJuego(
            tipoJuego: .retoRelampago,
            duracionSegundos: gameDuration,
            respuestasCorrectas: correctCount,
            respuestasTotales: answeredCount,
            puntuacion: totalPoints
        )
        
        progressManager.registrarSesionJuego(session)
        
        // Update progress for answered questions
        for i in 0..<min(currentQuestionIndex, questions.count) {
            let question = questions[i]
            let isCorrect = i < correctCount  // Simplification
            progressManager.registrarRespuesta(elementoID: question.relatedElementId, correcta: isCorrect)
        }
    }
    
    // MARK: - Computed Properties
    var performanceLevel: String {
        if correctCount >= 40 { return "¡Impresionante!" }
        else if correctCount >= 30 { return "¡Excelente!" }
        else if correctCount >= 20 { return "¡Muy bien!" }
        else if correctCount >= 10 { return "¡Buen trabajo!" }
        else { return "¡Sigue practicando!" }
    }
    
    var performanceEmoji: String {
        if correctCount >= 40 { return "🏆" }
        else if correctCount >= 30 { return "🌟" }
        else if correctCount >= 20 { return "⚡" }
        else if correctCount >= 10 { return "💪" }
        else { return "📚" }
    }
}
