import SwiftUI

struct PeriodicTableView: View {
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 4) {
                // Rows 1-7
                ForEach(0..<7) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<18) { col in
                            if let element = getElement(row: row, col: col) {
                                ElementCard(element: element)
                            } else {
                                Color.clear
                                    .frame(width: 70, height: 70)
                            }
                        }
                    }
                }
                
                Spacer().frame(height: 20)
                
                // Lantánidos y Actínidos
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(lanthanides) { element in
                            ElementCard(element: element)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(actinides) { element in
                            ElementCard(element: element)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
    
    func getElement(row: Int, col: Int) -> Element? {
        let position = (row, col)
        return elements.first { $0.row == row && $0.col == col }
    }
}

struct ElementCard: View {
    let element: Element
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(element.number)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(element.category.textColor)
            
            Text(element.symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(element.category.textColor)
            
            Text(element.name)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(element.category.textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: 70, height: 70)
        .background(element.category.backgroundColor)
        .cornerRadius(8)
    }
}

struct Element: Identifiable {
    let id = UUID()
    let number: Int
    let symbol: String
    let name: String
    let category: ElementCategory
    let row: Int
    let col: Int
}

enum ElementCategory {
    case alkaliMetal
    case alkalineEarthMetal
    case transitionMetal
    case postTransitionMetal
    case metalloid
    case nonmetal
    case halogen
    case nobleGas
    case lanthanide
    case actinide
    
    var backgroundColor: Color {
        switch self {
        case .alkaliMetal:
            return Color(red: 0.85, green: 0.95, blue: 0.95)
        case .alkalineEarthMetal:
            return Color(red: 1.0, green: 0.9, blue: 0.9)
        case .transitionMetal:
            return Color(red: 0.95, green: 0.92, blue: 1.0)
        case .postTransitionMetal:
            return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .metalloid:
            return Color(red: 1.0, green: 0.95, blue: 0.85)
        case .nonmetal:
            return Color(red: 0.9, green: 0.95, blue: 1.0)
        case .halogen:
            return Color(red: 1.0, green: 0.98, blue: 0.9)
        case .nobleGas:
            return Color(red: 1.0, green: 0.9, blue: 0.95)
        case .lanthanide:
            return Color(red: 0.92, green: 0.95, blue: 1.0)
        case .actinide:
            return Color(red: 1.0, green: 0.93, blue: 0.88)
        }
    }
    
    var textColor: Color {
        switch self {
        case .alkaliMetal:
            return Color(red: 0.0, green: 0.5, blue: 0.6)
        case .alkalineEarthMetal:
            return Color(red: 0.8, green: 0.2, blue: 0.2)
        case .transitionMetal:
            return Color(red: 0.4, green: 0.3, blue: 0.8)
        case .postTransitionMetal:
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .metalloid:
            return Color(red: 0.6, green: 0.4, blue: 0.0)
        case .nonmetal:
            return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .halogen:
            return Color(red: 0.5, green: 0.5, blue: 0.0)
        case .nobleGas:
            return Color(red: 0.8, green: 0.3, blue: 0.5)
        case .lanthanide:
            return Color(red: 0.3, green: 0.4, blue: 0.7)
        case .actinide:
            return Color(red: 0.8, green: 0.35, blue: 0.2)
        }
    }
}

// Elementos de la tabla periódica
let elements: [Element] = [
    // Fila 1
    Element(number: 1, symbol: "H", name: "Hidrógeno", category: .nonmetal, row: 0, col: 0),
    Element(number: 2, symbol: "He", name: "Helio", category: .nobleGas, row: 0, col: 17),
    
    // Fila 2
    Element(number: 3, symbol: "Li", name: "Litio", category: .alkaliMetal, row: 1, col: 0),
    Element(number: 4, symbol: "Be", name: "Berilio", category: .alkalineEarthMetal, row: 1, col: 1),
    Element(number: 5, symbol: "B", name: "Boro", category: .metalloid, row: 1, col: 12),
    Element(number: 6, symbol: "C", name: "Carbono", category: .nonmetal, row: 1, col: 13),
    Element(number: 7, symbol: "N", name: "Nitrógeno", category: .nonmetal, row: 1, col: 14),
    Element(number: 8, symbol: "O", name: "Oxígeno", category: .nonmetal, row: 1, col: 15),
    Element(number: 9, symbol: "F", name: "Flúor", category: .halogen, row: 1, col: 16),
    Element(number: 10, symbol: "Ne", name: "Neón", category: .nobleGas, row: 1, col: 17),
    
    // Fila 3
    Element(number: 11, symbol: "Na", name: "Sodio", category: .alkaliMetal, row: 2, col: 0),
    Element(number: 12, symbol: "Mg", name: "Magnesio", category: .alkalineEarthMetal, row: 2, col: 1),
    Element(number: 13, symbol: "Al", name: "Aluminio", category: .postTransitionMetal, row: 2, col: 12),
    Element(number: 14, symbol: "Si", name: "Silicio", category: .metalloid, row: 2, col: 13),
    Element(number: 15, symbol: "P", name: "Fósforo", category: .nonmetal, row: 2, col: 14),
    Element(number: 16, symbol: "S", name: "Azufre", category: .nonmetal, row: 2, col: 15),
    Element(number: 17, symbol: "Cl", name: "Cloro", category: .halogen, row: 2, col: 16),
    Element(number: 18, symbol: "Ar", name: "Argón", category: .nobleGas, row: 2, col: 17),
    
    // Fila 4
    Element(number: 19, symbol: "K", name: "Potasio", category: .alkaliMetal, row: 3, col: 0),
    Element(number: 20, symbol: "Ca", name: "Calcio", category: .alkalineEarthMetal, row: 3, col: 1),
    Element(number: 21, symbol: "Sc", name: "Escandio", category: .transitionMetal, row: 3, col: 2),
    Element(number: 22, symbol: "Ti", name: "Titanio", category: .transitionMetal, row: 3, col: 3),
    Element(number: 23, symbol: "V", name: "Vanadio", category: .transitionMetal, row: 3, col: 4),
    Element(number: 24, symbol: "Cr", name: "Cromo", category: .transitionMetal, row: 3, col: 5),
    Element(number: 25, symbol: "Mn", name: "Manganeso", category: .transitionMetal, row: 3, col: 6),
    Element(number: 26, symbol: "Fe", name: "Hierro", category: .transitionMetal, row: 3, col: 7),
    Element(number: 27, symbol: "Co", name: "Cobalto", category: .transitionMetal, row: 3, col: 8),
    Element(number: 28, symbol: "Ni", name: "Níquel", category: .transitionMetal, row: 3, col: 9),
    Element(number: 29, symbol: "Cu", name: "Cobre", category: .transitionMetal, row: 3, col: 10),
    Element(number: 30, symbol: "Zn", name: "Zinc", category: .transitionMetal, row: 3, col: 11),
    Element(number: 31, symbol: "Ga", name: "Galio", category: .postTransitionMetal, row: 3, col: 12),
    Element(number: 32, symbol: "Ge", name: "Germanio", category: .metalloid, row: 3, col: 13),
    Element(number: 33, symbol: "As", name: "Arsénico", category: .metalloid, row: 3, col: 14),
    Element(number: 34, symbol: "Se", name: "Selenio", category: .nonmetal, row: 3, col: 15),
    Element(number: 35, symbol: "Br", name: "Bromo", category: .halogen, row: 3, col: 16),
    Element(number: 36, symbol: "Kr", name: "Kriptón", category: .nobleGas, row: 3, col: 17),
    
    // Fila 5
    Element(number: 37, symbol: "Rb", name: "Rubidio", category: .alkaliMetal, row: 4, col: 0),
    Element(number: 38, symbol: "Sr", name: "Estroncio", category: .alkalineEarthMetal, row: 4, col: 1),
    Element(number: 39, symbol: "Y", name: "Itrio", category: .transitionMetal, row: 4, col: 2),
    Element(number: 40, symbol: "Zr", name: "Circonio", category: .transitionMetal, row: 4, col: 3),
    Element(number: 41, symbol: "Nb", name: "Niobio", category: .transitionMetal, row: 4, col: 4),
    Element(number: 42, symbol: "Mo", name: "Molibdeno", category: .transitionMetal, row: 4, col: 5),
    Element(number: 43, symbol: "Tc", name: "Tecnecio", category: .transitionMetal, row: 4, col: 6),
    Element(number: 44, symbol: "Ru", name: "Rutenio", category: .transitionMetal, row: 4, col: 7),
    Element(number: 45, symbol: "Rh", name: "Rodio", category: .transitionMetal, row: 4, col: 8),
    Element(number: 46, symbol: "Pd", name: "Paladio", category: .transitionMetal, row: 4, col: 9),
    Element(number: 47, symbol: "Ag", name: "Plata", category: .transitionMetal, row: 4, col: 10),
    Element(number: 48, symbol: "Cd", name: "Cadmio", category: .transitionMetal, row: 4, col: 11),
    Element(number: 49, symbol: "In", name: "Indio", category: .postTransitionMetal, row: 4, col: 12),
    Element(number: 50, symbol: "Sn", name: "Estaño", category: .postTransitionMetal, row: 4, col: 13),
    Element(number: 51, symbol: "Sb", name: "Antimonio", category: .metalloid, row: 4, col: 14),
    Element(number: 52, symbol: "Te", name: "Telurio", category: .metalloid, row: 4, col: 15),
    Element(number: 53, symbol: "I", name: "Yodo", category: .halogen, row: 4, col: 16),
    Element(number: 54, symbol: "Xe", name: "Xenón", category: .nobleGas, row: 4, col: 17),
    
    // Fila 6
    Element(number: 55, symbol: "Cs", name: "Cesio", category: .alkaliMetal, row: 5, col: 0),
    Element(number: 56, symbol: "Ba", name: "Bario", category: .alkalineEarthMetal, row: 5, col: 1),
    Element(number: 57, symbol: "La", name: "Lantano", category: .lanthanide, row: 5, col: 2),
    Element(number: 72, symbol: "Hf", name: "Hafnio", category: .transitionMetal, row: 5, col: 3),
    Element(number: 73, symbol: "Ta", name: "Tántalo", category: .transitionMetal, row: 5, col: 4),
    Element(number: 74, symbol: "W", name: "Tungsteno", category: .transitionMetal, row: 5, col: 5),
    Element(number: 75, symbol: "Re", name: "Renio", category: .transitionMetal, row: 5, col: 6),
    Element(number: 76, symbol: "Os", name: "Osmio", category: .transitionMetal, row: 5, col: 7),
    Element(number: 77, symbol: "Ir", name: "Iridio", category: .transitionMetal, row: 5, col: 8),
    Element(number: 78, symbol: "Pt", name: "Platino", category: .transitionMetal, row: 5, col: 9),
    Element(number: 79, symbol: "Au", name: "Oro", category: .transitionMetal, row: 5, col: 10),
    Element(number: 80, symbol: "Hg", name: "Mercurio", category: .transitionMetal, row: 5, col: 11),
    Element(number: 81, symbol: "Tl", name: "Talio", category: .postTransitionMetal, row: 5, col: 12),
    Element(number: 82, symbol: "Pb", name: "Plomo", category: .postTransitionMetal, row: 5, col: 13),
    Element(number: 83, symbol: "Bi", name: "Bismuto", category: .postTransitionMetal, row: 5, col: 14),
    Element(number: 84, symbol: "Po", name: "Polonio", category: .metalloid, row: 5, col: 15),
    Element(number: 85, symbol: "At", name: "Astato", category: .halogen, row: 5, col: 16),
    Element(number: 86, symbol: "Rn", name: "Radón", category: .nobleGas, row: 5, col: 17),
    
    // Fila 7
    Element(number: 87, symbol: "Fr", name: "Francio", category: .alkaliMetal, row: 6, col: 0),
    Element(number: 88, symbol: "Ra", name: "Radio", category: .alkalineEarthMetal, row: 6, col: 1),
    Element(number: 89, symbol: "Ac", name: "Actinio", category: .actinide, row: 6, col: 2),
    Element(number: 104, symbol: "Rf", name: "Rutherfordio", category: .transitionMetal, row: 6, col: 3),
    Element(number: 105, symbol: "Db", name: "Dubnio", category: .transitionMetal, row: 6, col: 4),
    Element(number: 106, symbol: "Sg", name: "Seaborgio", category: .transitionMetal, row: 6, col: 5),
    Element(number: 107, symbol: "Bh", name: "Bohrio", category: .transitionMetal, row: 6, col: 6),
    Element(number: 108, symbol: "Hs", name: "Hasio", category: .transitionMetal, row: 6, col: 7),
    Element(number: 109, symbol: "Mt", name: "Meitnerio", category: .transitionMetal, row: 6, col: 8),
    Element(number: 110, symbol: "Ds", name: "Darmstatio", category: .transitionMetal, row: 6, col: 9),
    Element(number: 111, symbol: "Rg", name: "Roentgenio", category: .transitionMetal, row: 6, col: 10),
    Element(number: 112, symbol: "Cn", name: "Copernicio", category: .transitionMetal, row: 6, col: 11),
    Element(number: 113, symbol: "Nh", name: "Nihonio", category: .postTransitionMetal, row: 6, col: 12),
    Element(number: 114, symbol: "Fl", name: "Flerovio", category: .postTransitionMetal, row: 6, col: 13),
    Element(number: 115, symbol: "Mc", name: "Moscovio", category: .postTransitionMetal, row: 6, col: 14),
    Element(number: 116, symbol: "Lv", name: "Livermorio", category: .postTransitionMetal, row: 6, col: 15),
    Element(number: 117, symbol: "Ts", name: "Teneso", category: .halogen, row: 6, col: 16),
    Element(number: 118, symbol: "Og", name: "Oganesón", category: .nobleGas, row: 6, col: 17),
]

// Lantánidos
let lanthanides: [Element] = [
    Element(number: 58, symbol: "Ce", name: "Cerio", category: .lanthanide, row: 8, col: 3),
    Element(number: 59, symbol: "Pr", name: "Praseodimio", category: .lanthanide, row: 8, col: 4),
    Element(number: 60, symbol: "Nd", name: "Neodimio", category: .lanthanide, row: 8, col: 5),
    Element(number: 61, symbol: "Pm", name: "Prometio", category: .lanthanide, row: 8, col: 6),
    Element(number: 62, symbol: "Sm", name: "Samario", category: .lanthanide, row: 8, col: 7),
    Element(number: 63, symbol: "Eu", name: "Europio", category: .lanthanide, row: 8, col: 8),
    Element(number: 64, symbol: "Gd", name: "Gadolinio", category: .lanthanide, row: 8, col: 9),
    Element(number: 65, symbol: "Tb", name: "Terbio", category: .lanthanide, row: 8, col: 10),
    Element(number: 66, symbol: "Dy", name: "Disprosio", category: .lanthanide, row: 8, col: 11),
    Element(number: 67, symbol: "Ho", name: "Holmio", category: .lanthanide, row: 8, col: 12),
    Element(number: 68, symbol: "Er", name: "Erbio", category: .lanthanide, row: 8, col: 13),
    Element(number: 69, symbol: "Tm", name: "Tulio", category: .lanthanide, row: 8, col: 14),
    Element(number: 70, symbol: "Yb", name: "Iterbio", category: .lanthanide, row: 8, col: 15),
    Element(number: 71, symbol: "Lu", name: "Lutecio", category: .lanthanide, row: 8, col: 16),
]

// Actínidos
let actinides: [Element] = [
    Element(number: 90, symbol: "Th", name: "Torio", category: .actinide, row: 9, col: 3),
    Element(number: 91, symbol: "Pa", name: "Protactinio", category: .actinide, row: 9, col: 4),
    Element(number: 92, symbol: "U", name: "Uranio", category: .actinide, row: 9, col: 5),
    Element(number: 93, symbol: "Np", name: "Neptunio", category: .actinide, row: 9, col: 6),
    Element(number: 94, symbol: "Pu", name: "Plutonio", category: .actinide, row: 9, col: 7),
    Element(number: 95, symbol: "Am", name: "Americio", category: .actinide, row: 9, col: 8),
    Element(number: 96, symbol: "Cm", name: "Curio", category: .actinide, row: 9, col: 9),
    Element(number: 97, symbol: "Bk", name: "Berkelio", category: .actinide, row: 9, col: 10),
    Element(number: 98, symbol: "Cf", name: "Californio", category: .actinide, row: 9, col: 11),
    Element(number: 99, symbol: "Es", name: "Einstenio", category: .actinide, row: 9, col: 12),
    Element(number: 100, symbol: "Fm", name: "Fermio", category: .actinide, row: 9, col: 13),
    Element(number: 101, symbol: "Md", name: "Mendelevio", category: .actinide, row: 9, col: 14),
    Element(number: 102, symbol: "No", name: "Nobelio", category: .actinide, row: 9, col: 15),
    Element(number: 103, symbol: "Lr", name: "Lawrencio", category: .actinide, row: 9, col: 16),
]

#Preview {
    PeriodicTableView()
}
