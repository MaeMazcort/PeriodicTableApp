//
//  QuizQuestion.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Model for quiz questions with dynamic generation
//

import Foundation

// MARK: - Question Type
enum QuizQuestionType: CaseIterable {
    case symbolFromName      // ¿Cuál es el símbolo de [elemento]?
    case nameFromSymbol      // ¿Qué elemento tiene el símbolo [símbolo]?
    case familyFromName      // ¿A qué familia pertenece [elemento]?
    case stateFromName       // ¿En qué estado está [elemento] a 25°C?
    case periodFromName      // ¿En qué periodo está [elemento]?
    case groupFromName       // ¿En qué grupo está [elemento]?
    case atomicNumberFromName // ¿Cuál es el número atómico de [elemento]?
    case nameFromAtomicNumber // ¿Qué elemento tiene el número atómico [número]?
    
    var difficulty: Int {
        switch self {
        case .symbolFromName, .nameFromSymbol:
            return 1 // Fácil
        case .familyFromName, .stateFromName:
            return 2 // Medio
        case .periodFromName, .groupFromName, .atomicNumberFromName:
            return 3 // Difícil
        case .nameFromAtomicNumber:
            return 3 // Difícil
        }
    }
}

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable, Equatable {
    let id: UUID
    let questionText: String
    let correctAnswer: String
    let options: [String]
    let questionType: QuizQuestionType
    let relatedElementId: Int
    
    init(
        id: UUID = UUID(),
        questionText: String,
        correctAnswer: String,
        options: [String],
        questionType: QuizQuestionType,
        relatedElementId: Int
    ) {
        self.id = id
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.options = options.shuffled() // Mezclar opciones
        self.questionType = questionType
        self.relatedElementId = relatedElementId
    }
}

// MARK: - Question Generator
class QuizQuestionGenerator {
    
    static func generateQuestions(
        from elementos: [Elemento],
        count: Int,
        difficulty: QuizDifficulty = .mixed
    ) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        var usedElements = Set<Int>()
        
        // Filtrar tipos de pregunta según dificultad
        let questionTypes = getQuestionTypes(for: difficulty)
        
        while questions.count < count && usedElements.count < elementos.count {
            // Seleccionar elemento aleatorio no usado
            guard let elemento = elementos.filter({ !usedElements.contains($0.id) }).randomElement() else {
                break
            }
            
            // Seleccionar tipo de pregunta aleatorio
            guard let questionType = questionTypes.randomElement() else {
                break
            }
            
            // Generar pregunta
            if let question = generateQuestion(
                type: questionType,
                for: elemento,
                allElements: elementos
            ) {
                questions.append(question)
                usedElements.insert(elemento.id)
            }
        }
        
        return questions.shuffled()
    }
    
    private static func getQuestionTypes(for difficulty: QuizDifficulty) -> [QuizQuestionType] {
        switch difficulty {
        case .easy:
            return [.symbolFromName, .nameFromSymbol]
        case .medium:
            return [.symbolFromName, .nameFromSymbol, .familyFromName, .stateFromName]
        case .hard:
            return [.periodFromName, .groupFromName, .atomicNumberFromName, .nameFromAtomicNumber]
        case .mixed:
            return QuizQuestionType.allCases
        }
    }
    
    private static func generateQuestion(
        type: QuizQuestionType,
        for elemento: Elemento,
        allElements: [Elemento]
    ) -> QuizQuestion? {
        
        switch type {
        case .symbolFromName:
            return generateSymbolFromNameQuestion(elemento: elemento, allElements: allElements)
            
        case .nameFromSymbol:
            return generateNameFromSymbolQuestion(elemento: elemento, allElements: allElements)
            
        case .familyFromName:
            return generateFamilyQuestion(elemento: elemento, allElements: allElements)
            
        case .stateFromName:
            return generateStateQuestion(elemento: elemento, allElements: allElements)
            
        case .periodFromName:
            return generatePeriodQuestion(elemento: elemento, allElements: allElements)
            
        case .groupFromName:
            return generateGroupQuestion(elemento: elemento, allElements: allElements)
            
        case .atomicNumberFromName:
            return generateAtomicNumberQuestion(elemento: elemento, allElements: allElements)
            
        case .nameFromAtomicNumber:
            return generateNameFromAtomicNumberQuestion(elemento: elemento, allElements: allElements)
        }
    }
    
    // MARK: - Question Generators
    
    private static func generateSymbolFromNameQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let wrongOptions = allElements
            .filter { $0.id != elemento.id }
            .shuffled()
            .prefix(3)
            .map { $0.simbolo }
        
        let options = ([elemento.simbolo] + wrongOptions).map { String($0) }
        
        return QuizQuestion(
            questionText: "¿Cuál es el símbolo del \(elemento.nombreES)?",
            correctAnswer: elemento.simbolo,
            options: options,
            questionType: .symbolFromName,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateNameFromSymbolQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let wrongOptions = allElements
            .filter { $0.id != elemento.id }
            .shuffled()
            .prefix(3)
            .map { $0.nombreES }
        
        let options = ([elemento.nombreES] + wrongOptions).map { String($0) }
        
        return QuizQuestion(
            questionText: "¿Qué elemento tiene el símbolo '\(elemento.simbolo)'?",
            correctAnswer: elemento.nombreES,
            options: options,
            questionType: .nameFromSymbol,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateFamilyQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let allFamilies = Set(allElements.map { $0.familia })
        let wrongFamilies = allFamilies
            .filter { $0 != elemento.familia }
            .shuffled()
            .prefix(3)
        
        let options = ([elemento.familia] + Array(wrongFamilies)).map { $0.rawValue }
        
        return QuizQuestion(
            questionText: "¿A qué familia pertenece el \(elemento.nombreES)?",
            correctAnswer: elemento.familia.rawValue,
            options: options,
            questionType: .familyFromName,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateStateQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let allStates = Set(allElements.map { $0.estado25C })
        let wrongStates = allStates
            .filter { $0 != elemento.estado25C }
            .shuffled()
            .prefix(3)
        
        let options = ([elemento.estado25C] + Array(wrongStates)).map { $0.rawValue }
        
        return QuizQuestion(
            questionText: "¿En qué estado se encuentra el \(elemento.nombreES) a 25°C?",
            correctAnswer: elemento.estado25C.rawValue,
            options: options,
            questionType: .stateFromName,
            relatedElementId: elemento.id
        )
    }
    
    private static func generatePeriodQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let allPeriods = Set(allElements.map { $0.periodo })
        let wrongPeriods = allPeriods
            .filter { $0 != elemento.periodo }
            .shuffled()
            .prefix(3)
        
        let options = ([elemento.periodo] + Array(wrongPeriods))
            .map { String($0) }
        
        return QuizQuestion(
            questionText: "¿En qué periodo de la tabla periódica está el \(elemento.nombreES)?",
            correctAnswer: String(elemento.periodo),
            options: options,
            questionType: .periodFromName,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateGroupQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion? {
        guard let elementoGrupo = elemento.grupo else { return nil }
        
        let allGroups = Set(allElements.compactMap { $0.grupo })
        let wrongGroups = allGroups
            .filter { $0 != elementoGrupo }
            .shuffled()
            .prefix(3)
        
        let options = ([elementoGrupo] + Array(wrongGroups))
            .map { String($0) }
        
        return QuizQuestion(
            questionText: "¿En qué grupo de la tabla periódica está el \(elemento.nombreES)?",
            correctAnswer: String(elementoGrupo),
            options: options,
            questionType: .groupFromName,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateAtomicNumberQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let wrongNumbers = allElements
            .filter { $0.id != elemento.id }
            .shuffled()
            .prefix(3)
            .map { String($0.id) }
        
        let options = ([String(elemento.id)] + wrongNumbers)
        
        return QuizQuestion(
            questionText: "¿Cuál es el número atómico del \(elemento.nombreES)?",
            correctAnswer: String(elemento.id),
            options: options,
            questionType: .atomicNumberFromName,
            relatedElementId: elemento.id
        )
    }
    
    private static func generateNameFromAtomicNumberQuestion(elemento: Elemento, allElements: [Elemento]) -> QuizQuestion {
        let wrongOptions = allElements
            .filter { $0.id != elemento.id }
            .shuffled()
            .prefix(3)
            .map { $0.nombreES }
        
        let options = ([elemento.nombreES] + wrongOptions)
        
        return QuizQuestion(
            questionText: "¿Qué elemento tiene el número atómico \(elemento.id)?",
            correctAnswer: elemento.nombreES,
            options: options,
            questionType: .nameFromAtomicNumber,
            relatedElementId: elemento.id
        )
    }
}

// MARK: - Quiz Difficulty
enum QuizDifficulty: String, CaseIterable, Identifiable {
    case easy = "Fácil"
    case medium = "Medio"
    case hard = "Difícil"
    case mixed = "Mixto"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        case .mixed: return "shuffle.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "51cf66"
        case .medium: return "ffa94d"
        case .hard: return "ff6b6b"
        case .mixed: return "667eea"
        }
    }
    
    var questionCount: Int {
        switch self {
        case .easy: return 10
        case .medium: return 15
        case .hard: return 20
        case .mixed: return 15
        }
    }
}
