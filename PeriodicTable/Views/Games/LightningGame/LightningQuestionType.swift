//
//  LightningQuestion.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Fast-paced questions for lightning challenge
//

import Foundation
import SwiftUI

// MARK: - Question Type
enum LightningQuestionType: CaseIterable {
    case symbolTrue          // "El símbolo de [elemento] es [X]" - V/F
    case isMetal            // "[Elemento] es un metal" - V/F
    case isGas              // "[Elemento] es un gas a 25°C" - V/F
    case groupNumber        // "[Elemento] está en el grupo [X]" - V/F
    case periodNumber       // "[Elemento] está en el periodo [X]" - V/F
    case symbolMatch        // "¿Cuál es [símbolo]?" - Múltiple
    case familyMatch        // "[Elemento] es un [familia]" - V/F
    
    var basePoints: Int {
        switch self {
        case .symbolTrue, .symbolMatch:
            return 10
        case .isMetal, .isGas:
            return 15
        case .groupNumber, .periodNumber:
            return 20
        case .familyMatch:
            return 15
        }
    }
}

// MARK: - Lightning Question Model
struct LightningQuestion: Identifiable, Equatable {
    let id: UUID
    let questionText: String
    let correctAnswer: String
    let options: [String]?  // nil for true/false
    let questionType: LightningQuestionType
    let basePoints: Int
    let relatedElementId: Int
    
    var isTrueFalse: Bool {
        options == nil
    }
    
    init(
        id: UUID = UUID(),
        questionText: String,
        correctAnswer: String,
        options: [String]? = nil,
        questionType: LightningQuestionType,
        relatedElementId: Int
    ) {
        self.id = id
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.options = options
        self.questionType = questionType
        self.basePoints = questionType.basePoints
        self.relatedElementId = relatedElementId
    }
}

// MARK: - Question Generator
class LightningQuestionGenerator {
    
    static func generateQuestions(from elementos: [Elemento], count: Int = 100) -> [LightningQuestion] {
        var questions: [LightningQuestion] = []
        
        for _ in 0..<count {
            guard let elemento = elementos.randomElement() else { continue }
            guard let questionType = LightningQuestionType.allCases.randomElement() else { continue }
            
            if let question = generateQuestion(type: questionType, for: elemento, allElements: elementos) {
                questions.append(question)
            }
        }
        
        return questions.shuffled()
    }
    
    private static func generateQuestion(
        type: LightningQuestionType,
        for elemento: Elemento,
        allElements: [Elemento]
    ) -> LightningQuestion? {
        
        switch type {
        case .symbolTrue:
            return generateSymbolTrueFalse(elemento: elemento, allElements: allElements)
        case .isMetal:
            return generateIsMetalQuestion(elemento: elemento)
        case .isGas:
            return generateIsGasQuestion(elemento: elemento)
        case .groupNumber:
            return generateGroupQuestion(elemento: elemento)
        case .periodNumber:
            return generatePeriodQuestion(elemento: elemento)
        case .symbolMatch:
            return generateSymbolMultiple(elemento: elemento, allElements: allElements)
        case .familyMatch:
            return generateFamilyQuestion(elemento: elemento)
        }
    }
    
    // MARK: - Question Generators
    
    private static func generateSymbolTrueFalse(elemento: Elemento, allElements: [Elemento]) -> LightningQuestion {
        let isTrue = Bool.random()
        let displaySymbol = isTrue ? elemento.simbolo : allElements.randomElement()?.simbolo ?? "X"
        
        return LightningQuestion(
            questionText: "El símbolo de \(elemento.nombreES) es '\(displaySymbol)'",
            correctAnswer: isTrue ? "Verdadero" : "Falso",
            options: nil,
            questionType: .symbolTrue,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateSymbolMultiple(elemento: Elemento, allElements: [Elemento]) -> LightningQuestion {
        let wrongSymbols = allElements
            .filter { $0.id != elemento.id }
            .shuffled()
            .prefix(2)
            .map { $0.simbolo }
        
        let options = ([elemento.simbolo] + wrongSymbols).shuffled()
        
        return LightningQuestion(
            questionText: "¿Cuál es el símbolo de \(elemento.nombreES)?",
            correctAnswer: elemento.simbolo,
            options: options,
            questionType: .symbolMatch,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateIsMetalQuestion(elemento: Elemento) -> LightningQuestion {
        let metales = ["Metales Alcalinos", "Metales Alcalinotérreos", "Metales de Transición", "Lantánidos", "Actínidos", "Otros Metales"]
        let isMetal = metales.contains(elemento.familia.rawValue)
        
        return LightningQuestion(
            questionText: "\(elemento.nombreES) es un metal",
            correctAnswer: isMetal ? "Verdadero" : "Falso",
            options: nil,
            questionType: .isMetal,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateIsGasQuestion(elemento: Elemento) -> LightningQuestion {
        let isGas = elemento.estado25C.rawValue == "Gas"
        
        return LightningQuestion(
            questionText: "\(elemento.nombreES) es un gas a 25°C",
            correctAnswer: isGas ? "Verdadero" : "Falso",
            options: nil,
            questionType: .isGas,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateGroupQuestion(elemento: Elemento) -> LightningQuestion {
        let isTrue = Bool.random()
        let displayGroup = isTrue ? elemento.grupo : (1...18).randomElement() ?? 1
        
        return LightningQuestion(
            questionText: "\(elemento.nombreES) está en el grupo \(displayGroup)",
            correctAnswer: isTrue ? "Verdadero" : "Falso",
            options: nil,
            questionType: .groupNumber,
            relatedElementId: elemento.id
        )
    }
    
    private static func generatePeriodQuestion(elemento: Elemento) -> LightningQuestion {
        let isTrue = Bool.random()
        let displayPeriod = isTrue ? elemento.periodo : (1...7).randomElement() ?? 1
        
        return LightningQuestion(
            questionText: "\(elemento.nombreES) está en el periodo \(displayPeriod)",
            correctAnswer: isTrue ? "Verdadero" : "Falso",
            options: nil,
            questionType: .periodNumber,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateFamilyQuestion(elemento: Elemento) -> LightningQuestion {
        let familias = ["Metales Alcalinos", "No Metales", "Gases Nobles", "Halógenos", "Metales de Transición"]
        let isTrue = Bool.random()
        let displayFamily = isTrue ? elemento.familia.rawValue : (familias.filter { $0 != elemento.familia.rawValue }).randomElement() ?? "No Metales"
        
        // Simplificar nombres para preguntas rápidas
        let simplifiedFamily = simplifyFamilyName(displayFamily)
        
        return LightningQuestion(
            questionText: "\(elemento.nombreES) es un \(simplifiedFamily)",
            correctAnswer: isTrue ? "Verdadero" : "Falso",
            options: nil,
            questionType: .familyMatch,
            relatedElementId: elemento.id
        )
    }
    
    private static func simplifyFamilyName(_ family: String) -> String {
        switch family {
        case "Metales Alcalinos": return "metal alcalino"
        case "Metales Alcalinotérreos": return "metal alcalinotérreo"
        case "Metales de Transición": return "metal de transición"
        case "Otros Metales": return "metal"
        case "No Metales": return "no metal"
        case "Halógenos": return "halógeno"
        case "Gases Nobles": return "gas noble"
        case "Metaloides": return "metaloide"
        case "Lantánidos": return "lantánido"
        case "Actínidos": return "actínido"
        default: return family.lowercased()
        }
    }
}

