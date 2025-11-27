//
//  BingoCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Bingo card model and win conditions
//

import Foundation
import SwiftUI

// MARK: - Bingo Cell
struct BingoCell: Identifiable, Equatable {
    let id: Int  // Element ID
    let symbol: String
    let name: String
    let row: Int
    let col: Int
    var isMarked: Bool = false
    var wasCalled: Bool = false
    
    init(elemento: Elemento, row: Int, col: Int) {
        self.id = elemento.id
        self.symbol = elemento.simbolo
        self.name = elemento.nombreES
        self.row = row
        self.col = col
    }
}

// MARK: - Win Pattern
enum BingoWinPattern: String, CaseIterable {
    case horizontal1 = "Línea Horizontal (Fila 1)"
    case horizontal2 = "Línea Horizontal (Fila 2)"
    case horizontal3 = "Línea Horizontal (Fila 3)"
    case horizontal4 = "Línea Horizontal (Fila 4)"
    case horizontal5 = "Línea Horizontal (Fila 5)"
    case vertical1 = "Línea Vertical (Col 1)"
    case vertical2 = "Línea Vertical (Col 2)"
    case vertical3 = "Línea Vertical (Col 3)"
    case vertical4 = "Línea Vertical (Col 4)"
    case vertical5 = "Línea Vertical (Col 5)"
    case diagonal1 = "Diagonal (\\ )"
    case diagonal2 = "Diagonal (/ )"
    case fullCard = "¡BINGO! (Cartón Lleno)"
    
    var icon: String {
        switch self {
        case .horizontal1, .horizontal2, .horizontal3, .horizontal4, .horizontal5:
            return "arrow.left.and.right"
        case .vertical1, .vertical2, .vertical3, .vertical4, .vertical5:
            return "arrow.up.and.down"
        case .diagonal1, .diagonal2:
            return "arrow.up.left.and.down.right"
        case .fullCard:
            return "star.fill"
        }
    }
    
    var points: Int {
        switch self {
        case .horizontal1, .horizontal2, .horizontal3, .horizontal4, .horizontal5:
            return 100
        case .vertical1, .vertical2, .vertical3, .vertical4, .vertical5:
            return 100
        case .diagonal1, .diagonal2:
            return 150
        case .fullCard:
            return 500
        }
    }
    
    var shortName: String {
        switch self {
        case .horizontal1: return "Fila 1"
        case .horizontal2: return "Fila 2"
        case .horizontal3: return "Fila 3"
        case .horizontal4: return "Fila 4"
        case .horizontal5: return "Fila 5"
        case .vertical1: return "Col 1"
        case .vertical2: return "Col 2"
        case .vertical3: return "Col 3"
        case .vertical4: return "Col 4"
        case .vertical5: return "Col 5"
        case .diagonal1: return "Diagonal \\"
        case .diagonal2: return "Diagonal /"
        case .fullCard: return "¡BINGO!"
        }
    }
}

// MARK: - Bingo Card
struct BingoCard {
    var cells: [[BingoCell]]  // 5×5 grid
    
    init(elementos: [Elemento]) {
        // Select 25 random elements
        let selectedElements = elementos.shuffled().prefix(25)
        
        // Create 5×5 grid
        var grid: [[BingoCell]] = []
        var index = 0
        
        for row in 0..<5 {
            var rowCells: [BingoCell] = []
            for col in 0..<5 {
                let elemento = selectedElements[index]
                let cell = BingoCell(elemento: elemento, row: row, col: col)
                rowCells.append(cell)
                index += 1
            }
            grid.append(rowCells)
        }
        
        self.cells = grid
    }
    
    // MARK: - Win Checking
    func checkForWins() -> [BingoWinPattern] {
        var wins: [BingoWinPattern] = []
        
        // Check horizontals
        for row in 0..<5 {
            if cells[row].allSatisfy({ $0.isMarked }) {
                switch row {
                case 0: wins.append(.horizontal1)
                case 1: wins.append(.horizontal2)
                case 2: wins.append(.horizontal3)
                case 3: wins.append(.horizontal4)
                case 4: wins.append(.horizontal5)
                default: break
                }
            }
        }
        
        // Check verticals
        for col in 0..<5 {
            var allMarked = true
            for row in 0..<5 {
                if !cells[row][col].isMarked {
                    allMarked = false
                    break
                }
            }
            if allMarked {
                switch col {
                case 0: wins.append(.vertical1)
                case 1: wins.append(.vertical2)
                case 2: wins.append(.vertical3)
                case 3: wins.append(.vertical4)
                case 4: wins.append(.vertical5)
                default: break
                }
            }
        }
        
        // Check diagonal 1 (top-left to bottom-right)
        var diagonal1Complete = true
        for i in 0..<5 {
            if !cells[i][i].isMarked {
                diagonal1Complete = false
                break
            }
        }
        if diagonal1Complete {
            wins.append(.diagonal1)
        }
        
        // Check diagonal 2 (top-right to bottom-left)
        var diagonal2Complete = true
        for i in 0..<5 {
            if !cells[i][4-i].isMarked {
                diagonal2Complete = false
                break
            }
        }
        if diagonal2Complete {
            wins.append(.diagonal2)
        }
        
        // Check full card
        let allCells = cells.flatMap { $0 }
        if allCells.allSatisfy({ $0.isMarked }) {
            wins.append(.fullCard)
        }
        
        return wins
    }
    
    func hasElement(id: Int) -> Bool {
        let allCells = cells.flatMap { $0 }
        return allCells.contains(where: { $0.id == id })
    }
    
    mutating func markElement(id: Int) {
        for row in 0..<5 {
            for col in 0..<5 {
                if cells[row][col].id == id {
                    cells[row][col].isMarked = true
                    cells[row][col].wasCalled = true
                    return
                }
            }
        }
    }
    
    mutating func markAsCalledIfNotInCard(id: Int) {
        // Mark that this element was called but not in card
        // This is for visual feedback
    }
    
    var markedCount: Int {
        cells.flatMap { $0 }.filter { $0.isMarked }.count
    }
    
    var totalCells: Int {
        25
    }
}

// MARK: - Game Speed
enum BingoGameSpeed: String, CaseIterable, Identifiable {
    case slow = "Lento"
    case normal = "Normal"
    case fast = "Rápido"
    
    var id: String { rawValue }
    
    var interval: TimeInterval {
        switch self {
        case .slow: return 4.0
        case .normal: return 2.5
        case .fast: return 1.5
        }
    }
    
    var icon: String {
        switch self {
        case .slow: return "tortoise.fill"
        case .normal: return "hare.fill"
        case .fast: return "bolt.fill"
        }
    }
    
    var color: String {
        switch self {
        case .slow: return "51cf66"
        case .normal: return "ffa94d"
        case .fast: return "ff6b6b"
        }
    }
}

// MARK: - Game Mode
enum BingoGameMode: String, CaseIterable {
    case auto = "Automático"
    case manual = "Manual"
    
    var description: String {
        switch self {
        case .auto: return "Los elementos se cantan automáticamente"
        case .manual: return "Tú decides cuándo cantar el siguiente"
        }
    }
    
    var icon: String {
        switch self {
        case .auto: return "play.circle.fill"
        case .manual: return "hand.tap.fill"
        }
    }
}
