//
//  PairsCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Model for matching pairs game cards
//

import Foundation
import SwiftUI

// MARK: - Card Type
enum PairsCardType: Equatable {
    case symbol(String)        // Element symbol (e.g., "H")
    case atomicNumber(Int)     // Atomic number (e.g., 1)
    
    var displayText: String {
        switch self {
        case .symbol(let symbol):
            return symbol
        case .atomicNumber(let number):
            return "\(number)"
        }
    }
    
    var isSymbol: Bool {
        if case .symbol = self { return true }
        return false
    }
    
    var isNumber: Bool {
        if case .atomicNumber = self { return true }
        return false
    }
}

// MARK: - Pairs Card Model
struct PairsCard: Identifiable, Equatable {
    let id: UUID
    let elementId: Int          // The element ID (for matching)
    let elementName: String     // Element name (for display)
    let type: PairsCardType     // Symbol or atomic number
    var isFlipped: Bool = false
    var isMatched: Bool = false
    
    init(id: UUID = UUID(), elementId: Int, elementName: String, type: PairsCardType, isFlipped: Bool = false, isMatched: Bool = false) {
        self.id = id
        self.elementId = elementId
        self.elementName = elementName
        self.type = type
        self.isFlipped = isFlipped
        self.isMatched = isMatched
    }
    
    // Two cards match if they have the same elementId but different types
    func matches(_ other: PairsCard) -> Bool {
        return self.elementId == other.elementId && self.type != other.type
    }
}

// MARK: - Difficulty Levels
enum PairsDifficulty: String, CaseIterable, Identifiable {
    case easy = "Fácil"
    case medium = "Medio"
    case hard = "Difícil"
    
    var id: String { rawValue }
    
    var pairCount: Int {
        switch self {
        case .easy: return 6      // 12 cards total
        case .medium: return 10   // 20 cards total
        case .hard: return 15     // 30 cards total
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "square.grid.2x2.fill"
        case .medium: return "square.grid.3x3.fill"
        case .hard: return "square.grid.4x4.fill"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "51cf66"
        case .medium: return "ffa94d"
        case .hard: return "ff6b6b"
        }
    }
    
    var gridColumns: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }
}

// MARK: - Card Generator
class PairsCardGenerator {
    
    static func generateCards(from elementos: [Elemento], difficulty: PairsDifficulty) -> [PairsCard] {
        // Select random elements
        let selectedElements = elementos.shuffled().prefix(difficulty.pairCount)
        
        var cards: [PairsCard] = []
        
        // Create pairs: one symbol card and one number card for each element
        for elemento in selectedElements {
            // Symbol card
            let symbolCard = PairsCard(
                elementId: elemento.id,
                elementName: elemento.nombreES,
                type: .symbol(elemento.simbolo)
            )
            cards.append(symbolCard)
            
            // Atomic number card
            let numberCard = PairsCard(
                elementId: elemento.id,
                elementName: elemento.nombreES,
                type: .atomicNumber(elemento.id)
            )
            cards.append(numberCard)
        }
        
        // Shuffle all cards
        return cards.shuffled()
    }
}
