//
//  FamilyMapElement.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Model for family classification game
//

import Foundation
import SwiftUI

// MARK: - Chemical Families
enum ChemicalFamily: String, CaseIterable, Identifiable {
    case metalesAlcalinos = "Metales Alcalinos"
    case metalesAlcalinoterreos = "Metales Alcalinotérreos"
    case metalesTransicion = "Metales de Transición"
    case lantanidos = "Lantánidos"
    case actinidos = "Actínidos"
    case otrosMetales = "Otros Metales"
    case metaloides = "Metaloides"
    case noMetales = "No Metales"
    case halogenos = "Halógenos"
    case gasesNobles = "Gases Nobles"
    
    var id: String { rawValue }
    
    var shortName: String {
        switch self {
        case .metalesAlcalinos: return "Alcalinos"
        case .metalesAlcalinoterreos: return "Alcalinotérreos"
        case .metalesTransicion: return "Transición"
        case .lantanidos: return "Lantánidos"
        case .actinidos: return "Actínidos"
        case .otrosMetales: return "Otros Metales"
        case .metaloides: return "Metaloides"
        case .noMetales: return "No Metales"
        case .halogenos: return "Halógenos"
        case .gasesNobles: return "Gases Nobles"
        }
    }
    
    var color: String {
        switch self {
        case .metalesAlcalinos: return "ff6b6b"
        case .metalesAlcalinoterreos: return "ffa94d"
        case .metalesTransicion: return "ffd43b"
        case .lantanidos: return "51cf66"
        case .actinidos: return "37b24d"
        case .otrosMetales: return "339af0"
        case .metaloides: return "748ffc"
        case .noMetales: return "845ef7"
        case .halogenos: return "f06595"
        case .gasesNobles: return "cc5de8"
        }
    }
    
    var icon: String {
        switch self {
        case .metalesAlcalinos: return "flame.fill"
        case .metalesAlcalinoterreos: return "circle.hexagongrid.fill"
        case .metalesTransicion: return "sparkles"
        case .lantanidos: return "star.fill"
        case .actinidos: return "atom"
        case .otrosMetales: return "cube.fill"
        case .metaloides: return "triangle.fill"
        case .noMetales: return "circle.fill"
        case .halogenos: return "drop.fill"
        case .gasesNobles: return "cloud.fill"
        }
    }
    
    var description: String {
        switch self {
        case .metalesAlcalinos:
            return "Grupo 1: Muy reactivos, un electrón de valencia"
        case .metalesAlcalinoterreos:
            return "Grupo 2: Reactivos, dos electrones de valencia"
        case .metalesTransicion:
            return "Grupos 3-12: Duros, conductores, múltiples estados de oxidación"
        case .lantanidos:
            return "Elementos de tierras raras, periodo 6"
        case .actinidos:
            return "Elementos radiactivos, periodo 7"
        case .otrosMetales:
            return "Metales más blandos del bloque p"
        case .metaloides:
            return "Propiedades intermedias entre metales y no metales"
        case .noMetales:
            return "Buenos aislantes, diversos estados físicos"
        case .halogenos:
            return "Grupo 17: Muy reactivos, siete electrones de valencia"
        case .gasesNobles:
            return "Grupo 18: Inertes, capa de valencia completa"
        }
    }
}

// MARK: - Game Element Model
struct FamilyMapGameElement: Identifiable, Equatable {
    let id: Int
    let symbol: String
    let name: String
    let correctFamily: ChemicalFamily
    var isClassified: Bool = false
    var classifiedAs: ChemicalFamily?
    
    var isCorrect: Bool {
        guard let classifiedAs = classifiedAs else { return false }
        return classifiedAs == correctFamily
    }
    
    init(from elemento: Elemento) {
        self.id = elemento.id
        self.symbol = elemento.simbolo
        self.name = elemento.nombreES
        self.correctFamily = ChemicalFamily.from(familyString: elemento.familia.rawValue)
    }
    
    init(
        id: Int,
        symbol: String,
        name: String,
        correctFamily: ChemicalFamily,
        isClassified: Bool = false,
        classifiedAs: ChemicalFamily? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.correctFamily = correctFamily
        self.isClassified = isClassified
        self.classifiedAs = classifiedAs
    }
}

// MARK: - Family Mapping Extension
extension ChemicalFamily {
    static func from(familyString: String) -> ChemicalFamily {
        switch familyString {
        case "Metales Alcalinos":
            return .metalesAlcalinos
        case "Metales Alcalinotérreos":
            return .metalesAlcalinoterreos
        case "Metales de Transición":
            return .metalesTransicion
        case "Lantánidos":
            return .lantanidos
        case "Actínidos":
            return .actinidos
        case "Otros Metales":
            return .otrosMetales
        case "Metaloides":
            return .metaloides
        case "No Metales":
            return .noMetales
        case "Halógenos":
            return .halogenos
        case "Gases Nobles":
            return .gasesNobles
        default:
            return .noMetales // Default fallback
        }
    }
}

// MARK: - Difficulty Levels
enum FamilyMapDifficulty: String, CaseIterable, Identifiable {
    case easy = "Fácil"
    case medium = "Medio"
    case hard = "Difícil"
    
    var id: String { rawValue }
    
    var elementCount: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
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
    
    var timeEstimate: String {
        switch self {
        case .easy: return "3-5 min"
        case .medium: return "6-8 min"
        case .hard: return "10-12 min"
        }
    }
}

// MARK: - Game Mode
enum FamilyMapGameMode: String, CaseIterable {
    case buttons = "Botones"
    case dragDrop = "Arrastrar"
    
    var icon: String {
        switch self {
        case .buttons: return "hand.tap.fill"
        case .dragDrop: return "hand.draw.fill"
        }
    }
}
