//
//  ColorPalette.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct ColorPalette {
    // MARK: - Colores por Familia de Elementos
    
    /// Retorna el color apropiado para una familia, considerando el contexto de accesibilidad
    static func colorParaFamilia(_ familia: FamiliaElemento, highContrast: Bool = false) -> Color {
        if highContrast {
            return colorAltoContrasteParaFamilia(familia)
        } else {
            return colorNormalParaFamilia(familia)
        }
    }
    
    // MARK: - Colores Normales (tema adaptativo)
    private static func colorNormalParaFamilia(_ familia: FamiliaElemento) -> Color {
        switch familia {
        case .metalesAlcalinos:
            return Color("FamiliaAlcalinos") // Azul claro/oscuro
        case .metalesAlcalinoterreos:
            return Color("FamiliaAlcalinoterreos") // Naranja claro/oscuro
        case .lantanidos:
            return Color("FamiliaLantanidos") // Verde claro/oscuro
        case .actinidos:
            return Color("FamiliaActinidos") // Rosa claro/oscuro
        case .metalesTransicion:
            return Color("FamiliaTransicion") // Amarillo claro/oscuro
        case .metalesPosTrans:
            return Color("FamiliaPosTrans") // Cyan claro/oscuro
        case .metaloides:
            return Color("FamiliaMetaloides") // Turquesa claro/oscuro
        case .noMetales:
            return Color("FamiliaNoMetales") // Morado claro/oscuro
        case .halogenos:
            return Color("FamiliaHalogenos") // Rojo claro/oscuro
        case .gasesNobles:
            return Color("FamiliaGasesNobles") // Gris claro/oscuro
        }
    }
    
    // MARK: - Colores de Alto Contraste (AAA)
    private static func colorAltoContrasteParaFamilia(_ familia: FamiliaElemento) -> Color {
        switch familia {
        case .metalesAlcalinos:
            return Color("FamiliaAlcalinosHC")
        case .metalesAlcalinoterreos:
            return Color("FamiliaAlcalinoterreos HC")
        case .lantanidos:
            return Color("FamiliaLantanidosHC")
        case .actinidos:
            return Color("FamiliaActinidosHC")
        case .metalesTransicion:
            return Color("FamiliaTransicionHC")
        case .metalesPosTrans:
            return Color("FamiliaPostTransHC")
        case .metaloides:
            return Color("FamiliaMetaloidesHC")
        case .noMetales:
            return Color("FamiliaNoMetalesHC")
        case .halogenos:
            return Color("FamiliaHalogenosHC")
        case .gasesNobles:
            return Color("FamiliaGasesNoblesHC")
        }
    }
    
    // MARK: - Colores de Sistema (Semánticos)
    struct Sistema {
        static let primario = Color.accentColor
        static let secundario = Color.secondary
        static let fondo = Color(.systemBackground)
        static let fondoSecundario = Color(.secondarySystemBackground)
        static let fondoTerciario = Color(.tertiarySystemBackground)
        static let etiqueta = Color(.label)
        static let etiquetaSecundaria = Color(.secondaryLabel)
        static let separador = Color(.separator)
    }
    
    // MARK: - Colores Funcionales
    struct Funcional {
        static let exito = Color.green
        static let error = Color.red
        static let advertencia = Color.orange
        static let informacion = Color.blue
        static let neutro = Color.gray
    }
    
    // MARK: - Colores de Marca
    struct Marca {
        static let primario = Color(hexString: "667eea")
        static let secundario = Color(hexString: "764ba2")
    }
    
    // MARK: - Colores por Estado de Materia
    static func colorParaEstado(_ estado: EstadoMateria) -> Color {
        switch estado {
        case .solido:
            return Color.brown
        case .liquido:
            return Color.blue
        case .gas:
            return Color.purple
        case .desconocido:
            return Color.gray
        }
    }
    
    // MARK: - Colores por Nivel de Dominio
    static func colorParaNivelDominio(_ nivel: NivelDominio) -> Color {
        switch nivel {
        case .nuevo:
            return Color.gray
        case .aprendiendo:
            return Color.yellow
        case .enProgreso:
            return Color.orange
        case .dominado:
            return Color.green
        }
    }
    
    // MARK: - Gradientes
    struct Gradientes {
        static let fondo = LinearGradient(
            colors: [Sistema.fondo, Sistema.fondoSecundario],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let tarjeta = LinearGradient(
            colors: [Sistema.fondoSecundario, Sistema.fondoTerciario],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let acento = LinearGradient(
            colors: [Marca.primario, Marca.secundario],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Extensión de Color para Hex (opcional)
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func fromHex(_ hexString: String) -> Color {
        return Color(hexString: hexString)
    }
}

// MARK: - Notas de Implementación
/*
 Para que los colores funcionen correctamente:
 
 1. Crear un Asset Catalog (Assets.xcassets) en Xcode
 2. Agregar un Color Set para cada familia con:
    - Variante "Any Appearance" (tema claro)
    - Variante "Dark Appearance" (tema oscuro)
    - Variante "High Contrast" (ambos temas)
 
 3. Asegurar ratios de contraste:
    - AA: mínimo 4.5:1 para texto normal
    - AAA: mínimo 7:1 para texto normal
    - Usar herramientas como Contrast Checker de WebAIM
 
 4. Nombres sugeridos en Assets:
    - FamiliaAlcalinos, FamiliaAlcalinosHC
    - FamiliaAlcalinoterreos, FamiliaAlcalinoterre osHC
    - etc.
 
 5. Paleta de referencia (valores hex aproximados):
    Metales Alcalinos: #87CEEB (claro), #1E90FF (oscuro), #0000FF (HC)
    Metales Alcalinotérreos: #FFA500 (claro), #FF8C00 (oscuro), #FF4500 (HC)
    Lantánidos: #90EE90 (claro), #32CD32 (oscuro), #008000 (HC)
    Actínidos: #FFB6C1 (claro), #FF69B4 ( oscuro), #C71585 (HC)
    Metales de Transición: #FFFFE0 (claro), #FFD700 (oscuro), #DAA520 (HC)
    No Metales: #DDA0DD (claro), #BA55D3 (oscuro), #8B008B (HC)
    Halógenos: #FFB6C1 (claro), #DC143C (oscuro), #8B0000 (HC)
    Gases Nobles: #D3D3D3 (claro), #A9A9A9 (oscuro), #696969 (HC)
*/
