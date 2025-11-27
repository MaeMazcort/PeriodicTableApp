//
//  GuessPropertyQuestion.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Property guessing game model
//

import Foundation
import SwiftUI

// MARK: - Property Type
enum PropertyType: String, CaseIterable, Identifiable {
    case masaAtomica = "Masa Atómica"
    case puntoFusion = "Punto de Fusión"
    case puntoEbullicion = "Punto de Ebullición"
    case densidad = "Densidad"
    case electronegatividad = "Electronegatividad"
    case radioAtomico = "Radio Atómico"
    case energiaIonizacion = "Energía de Ionización"
    
    var id: String { rawValue }
    
    var unit: String {
        switch self {
        case .masaAtomica: return "u"
        case .puntoFusion, .puntoEbullicion: return "°C"
        case .densidad: return "g/cm³"
        case .electronegatividad: return ""  // Escala Pauling (sin unidad)
        case .radioAtomico: return "pm"
        case .energiaIonizacion: return "kJ/mol"
        }
    }
    
    var icon: String {
        switch self {
        case .masaAtomica: return "scalemass.fill"
        case .puntoFusion: return "thermometer.snowflake"
        case .puntoEbullicion: return "thermometer.sun.fill"
        case .densidad: return "cube.fill"
        case .electronegatividad: return "bolt.fill"
        case .radioAtomico: return "circle.dashed"
        case .energiaIonizacion: return "arrow.up.right"
        }
    }
    
    var color: String {
        switch self {
        case .masaAtomica: return "667eea"
        case .puntoFusion: return "51cf66"
        case .puntoEbullicion: return "ff6b6b"
        case .densidad: return "ffa94d"
        case .electronegatividad: return "ffd43b"
        case .radioAtomico: return "764ba2"
        case .energiaIonizacion: return "f093fb"
        }
    }
    
    var minValue: Double {
        switch self {
        case .masaAtomica: return 1.0
        case .puntoFusion: return -300.0
        case .puntoEbullicion: return -300.0
        case .densidad: return 0.0
        case .electronegatividad: return 0.5
        case .radioAtomico: return 30.0
        case .energiaIonizacion: return 300.0
        }
    }
    
    var maxValue: Double {
        switch self {
        case .masaAtomica: return 300.0
        case .puntoFusion: return 4000.0
        case .puntoEbullicion: return 6000.0
        case .densidad: return 25.0
        case .electronegatividad: return 4.0
        case .radioAtomico: return 300.0
        case .energiaIonizacion: return 2500.0
        }
    }
    
    var step: Double {
        switch self {
        case .masaAtomica: return 1.0
        case .puntoFusion, .puntoEbullicion: return 10.0
        case .densidad: return 0.1
        case .electronegatividad: return 0.1
        case .radioAtomico: return 5.0
        case .energiaIonizacion: return 10.0
        }
    }
    
    var description: String {
        switch self {
        case .masaAtomica:
            return "Masa promedio de un átomo del elemento"
        case .puntoFusion:
            return "Temperatura a la que el elemento se funde"
        case .puntoEbullicion:
            return "Temperatura a la que el elemento hierve"
        case .densidad:
            return "Masa por unidad de volumen"
        case .electronegatividad:
            return "Tendencia a atraer electrones (Escala Pauling)"
        case .radioAtomico:
            return "Distancia del núcleo al electrón más externo"
        case .energiaIonizacion:
            return "Energía para remover un electrón"
        }
    }
    
    // Tolerance for scoring (% of value)
    var excellentTolerance: Double { 0.05 }  // Within 5%
    var goodTolerance: Double { 0.15 }       // Within 15%
    var okTolerance: Double { 0.30 }         // Within 30%
}

// MARK: - Guess Property Question
struct GuessPropertyQuestion: Identifiable, Equatable {
    let id: UUID
    let elemento: Elemento
    let propertyType: PropertyType
    let correctValue: Double
    var userGuess: Double?
    var isAnswered: Bool = false
    
    init(elemento: Elemento, propertyType: PropertyType) {
        self.id = UUID()
        self.elemento = elemento
        self.propertyType = propertyType
        
        let fallback = (propertyType.minValue + propertyType.maxValue) / 2
        
        // Get correct value based on property type
        switch propertyType {
        case .masaAtomica:
            self.correctValue = elemento.masaAtomica ?? fallback
        case .puntoFusion:
            self.correctValue = elemento.puntoFusionC ?? fallback
        case .puntoEbullicion:
            self.correctValue = elemento.puntoEbullicionC ?? fallback
        case .densidad:
            self.correctValue = elemento.densidad ?? fallback
        case .electronegatividad:
            self.correctValue = elemento.electronegatividad ?? fallback
        case .radioAtomico:
            self.correctValue = elemento.radioAtomico ?? fallback
        case .energiaIonizacion:
            self.correctValue = elemento.energiaIonizacion ?? fallback
        }
    }
    
    // Calculate score based on accuracy
    func calculateScore() -> Int {
        guard let guess = userGuess else { return 0 }
        
        let percentError = abs(guess - correctValue) / correctValue
        
        if percentError <= propertyType.excellentTolerance {
            return 100  // Perfect!
        } else if percentError <= propertyType.goodTolerance {
            return 80   // Very good
        } else if percentError <= propertyType.okTolerance {
            return 60   // Good
        } else if percentError <= 0.50 {
            return 40   // OK
        } else if percentError <= 0.75 {
            return 20   // Not great
        } else {
            return 10   // Far off
        }
    }
    
    var percentError: Double {
        guard let guess = userGuess else { return 0 }
        return abs(guess - correctValue) / correctValue * 100
    }
    
    var accuracyLevel: AccuracyLevel {
        guard let guess = userGuess else { return .none }
        
        let percentError = abs(guess - correctValue) / correctValue
        
        if percentError <= propertyType.excellentTolerance {
            return .excellent
        } else if percentError <= propertyType.goodTolerance {
            return .good
        } else if percentError <= propertyType.okTolerance {
            return .ok
        } else if percentError <= 0.50 {
            return .fair
        } else {
            return .poor
        }
    }
}

// MARK: - Accuracy Level
enum AccuracyLevel {
    case none
    case excellent
    case good
    case ok
    case fair
    case poor
    
    var emoji: String {
        switch self {
        case .none: return ""
        case .excellent: return "🎯"
        case .good: return "🌟"
        case .ok: return "👍"
        case .fair: return "📊"
        case .poor: return "📚"
        }
    }
    
    var message: String {
        switch self {
        case .none: return ""
        case .excellent: return "¡Excelente!"
        case .good: return "¡Muy bien!"
        case .ok: return "¡Bien!"
        case .fair: return "No está mal"
        case .poor: return "Sigue practicando"
        }
    }
    
    var color: String {
        switch self {
        case .none: return "gray"
        case .excellent: return "51cf66"
        case .good: return "667eea"
        case .ok: return "ffd43b"
        case .fair: return "ffa94d"
        case .poor: return "ff6b6b"
        }
    }
}

// MARK: - Game Difficulty
enum GuessPropertyDifficulty: String, CaseIterable, Identifiable {
    case easy = "Fácil"
    case medium = "Medio"
    case hard = "Difícil"
    
    var id: String { rawValue }
    
    var questionCount: Int {
        switch self {
        case .easy: return 5
        case .medium: return 10
        case .hard: return 15
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "51cf66"
        case .medium: return "ffa94d"
        case .hard: return "ff6b6b"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "\(questionCount) preguntas · Elementos comunes"
        case .medium: return "\(questionCount) preguntas · Elementos variados"
        case .hard: return "\(questionCount) preguntas · Elementos raros"
        }
    }
}

