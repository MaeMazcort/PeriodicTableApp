//
//  QuizGameViewModel.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Quiz game logic with dynamic question generation
//

import Foundation
import SwiftUI
import Combine

// MARK: - Game State
enum QuizGameState: Equatable {
    case setup
    case playing
    case completed
}

// MARK: - Answer State
enum AnswerState: Equatable {
    case notAnswered
    case correct
    case incorrect
}

// MARK: - ViewModel
class QuizGameViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: String?
    @Published var answerState: AnswerState = .notAnswered
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var gameState: QuizGameState = .setup
    @Published var elapsedTime: Int = 0
    @Published var difficulty: QuizDifficulty = .mixed
    @Published var showFeedback: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?
    private var questionStartTime: Date?
    private var questionTimes: [Int: TimeInterval] = [:]
    private var answers: [Int: Bool] = [:]
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var canGoNext: Bool {
        return answerState != .notAnswered
    }
    
    var canGoBack: Bool {
        return currentQuestionIndex > 0
    }
    
    init() {}
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Game Control
    func startNewGame(elementos: [Elemento], difficulty: QuizDifficulty) {
        self.difficulty = difficulty
        self.questions = QuizQuestionGenerator.generateQuestions(
            from: elementos,
            count: difficulty.questionCount,
            difficulty: difficulty
        )
        
        self.currentQuestionIndex = 0
        self.selectedAnswer = nil
        self.answerState = .notAnswered
        self.correctCount = 0
        self.incorrectCount = 0
        self.elapsedTime = 0
        self.questionTimes = [:]
        self.answers = [:]
        self.gameState = .playing
        
        startTimer()
        questionStartTime = Date()
    }
    
    func selectAnswer(_ answer: String) {
        guard answerState == .notAnswered else { return }
        
        // Record question time only on first attempt
        if let startTime = questionStartTime, answers[currentQuestionIndex] == nil {
            questionTimes[currentQuestionIndex] = Date().timeIntervalSince(startTime)
        }
        
        selectedAnswer = answer
        
        // If this question was answered before, revert the old counts
        if let wasCorrectPreviously = answers[currentQuestionIndex] {
            if wasCorrectPreviously {
                correctCount -= 1
            } else {
                incorrectCount -= 1
            }
        }
        
        let isCorrect = answer == currentQuestion?.correctAnswer
        answers[currentQuestionIndex] = isCorrect
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            if isCorrect {
                answerState = .correct
                correctCount += 1
            } else {
                answerState = .incorrect
                incorrectCount += 1
            }
            showFeedback = true
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                currentQuestionIndex += 1
                resetQuestionState()
            }
            questionStartTime = Date()
        } else {
            endGame()
        }
    }
    
    func previousQuestion() {
        guard canGoBack else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            currentQuestionIndex -= 1
            resetQuestionState()
        }
        questionStartTime = Date()
    }
    
    private func resetQuestionState() {
        selectedAnswer = nil
        answerState = .notAnswered
        showFeedback = false
    }
    
    private func endGame() {
        stopTimer()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            gameState = .completed
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
            tipoJuego: .quiz,
            duracionSegundos: elapsedTime,
            respuestasCorrectas: correctCount,
            respuestasTotales: correctCount + incorrectCount,
            puntuacion: calculateScore()
        )
        
        progressManager.registrarSesionJuego(session)
        
        // Update individual element progress
        for (index, question) in questions.enumerated() {
            if let isCorrect = answers[index] {
                progressManager.registrarRespuesta(
                    elementoID: question.relatedElementId,
                    correcta: isCorrect
                )
            }
        }
    }
    
    private func calculateScore() -> Int {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        
        let accuracy = Double(correctCount) / Double(total)
        let baseScore = Int(accuracy * 1000)
        
        // Time bonus (faster = more points)
        let timeValues = questionTimes.values
        let avgTime = timeValues.isEmpty ? 0 : timeValues.reduce(0, +) / Double(timeValues.count)
        let timeBonus = max(0, Int((10 - avgTime) * 10))
        
        // Difficulty multiplier
        let difficultyMultiplier: Double
        switch difficulty {
        case .easy: difficultyMultiplier = 1.0
        case .medium: difficultyMultiplier = 1.5
        case .hard: difficultyMultiplier = 2.0
        case .mixed: difficultyMultiplier = 1.3
        }
        
        return Int(Double(baseScore + timeBonus) * difficultyMultiplier)
    }
    
    // MARK: - Computed Properties
    var accuracy: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total) * 100
    }
    
    var averageTimePerQuestion: Double {
        let timeValues = questionTimes.values
        guard !timeValues.isEmpty else { return 0 }
        return timeValues.reduce(0, +) / Double(timeValues.count)
    }
}
