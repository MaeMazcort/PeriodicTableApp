//
//  UserSettings.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation

struct UserSettings: Codable {
    // MARK: - Idioma y Localización
    var idioma: Idioma = .espanol
    
    // MARK: - Apariencia
    var temaVisual: TemaVisual = .sistema
    var usarAltoContraste: Bool = false
    var reducirMovimiento: Bool = false
    
    // MARK: - Accesibilidad - Texto
    var usarDynamicType: Bool = true
    var tamanoTextoPersonalizado: Double = 1.0 // Multiplicador
    var usarTextoBold: Bool = false
    
    // MARK: - Accesibilidad - Audio
    var velocidadTTS: Double = 1.0 // 0.5 a 2.0
    var vozTTS: String = "es-MX" // Locale de la voz
    var habilitarSonidos: Bool = true
    var volumenSonidos: Double = 0.7
    
    // MARK: - Accesibilidad - Táctil
    var habilitarHaptics: Bool = true
    var intensidadHaptics: Double = 1.0
    
    // MARK: - Preferencias de Aprendizaje
    var mostrarPistasAutomaticas: Bool = true
    var tiempoRespuestaQuiz: Int = 30 // segundos
    var dificultadInicial: Dificultad = .media
    
    // MARK: - Onboarding
    var completoOnboarding: Bool = false
    var fechaPrimeraApertura: Date?
    
    // MARK: - Funciones de Utilidad
    mutating func restaurarDefectos() {
        self = UserSettings()
    }
    
    func velocidadTTSNormalizada() -> Float {
        return Float(velocidadTTS.clamped(to: 0.5...2.0))
    }
}

// MARK: - Enums de Configuración

enum Idioma: String, Codable, CaseIterable {
    case espanol = "es"
    case ingles = "en"
    
    var nombre: String {
        switch self {
        case .espanol: return "Español"
        case .ingles: return "English"
        }
    }
    
    var codigo: String {
        return self.rawValue
    }
}

enum TemaVisual: String, Codable, CaseIterable {
    case claro = "light"
    case oscuro = "dark"
    case sistema = "system"
    
    var nombre: String {
        switch self {
        case .claro: return "Claro"
        case .oscuro: return "Oscuro"
        case .sistema: return "Sistema"
        }
    }
    
    var icono: String {
        switch self {
        case .claro: return "sun.max.fill"
        case .oscuro: return "moon.fill"
        case .sistema: return "sparkles"
        }
    }
}

enum Dificultad: String, Codable, CaseIterable {
    case facil = "easy"
    case media = "medium"
    case dificil = "hard"
    
    var nombre: String {
        switch self {
        case .facil: return "Fácil"
        case .media: return "Media"
        case .dificil: return "Difícil"
        }
    }
    
    var icono: String {
        switch self {
        case .facil: return "star.fill"
        case .media: return "star.leadinghalf.filled"
        case .dificil: return "flame.fill"
        }
    }
}

// MARK: - Extensión de Double para clamping
extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
