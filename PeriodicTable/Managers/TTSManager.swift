//
//  TTSManager.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import AVFoundation
import SwiftUI
import Combine

@MainActor
class TTSManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = TTSManager()
    
    // MARK: - Properties
    @Published var isPlaying: Bool = false
    @Published var currentRate: Float = AVSpeechUtteranceDefaultSpeechRate
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    // MARK: - Inicializador
    override init() {
        super.init()
        synthesizer.delegate = self
        configurarAudioSession()
    }
    
    // MARK: - Configuración de Audio
    private func configurarAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Error configurando sesión de audio: \(error)")
        }
    }
    
    // MARK: - Funciones Principales
    
    /// Pronuncia el nombre y símbolo de un elemento
    func pronunciarElemento(_ elemento: Elemento, idioma: Idioma = .espanol) {
        let nombre = idioma == .espanol ? elemento.nombreES : elemento.nombreEN
        let texto = "\(nombre), símbolo \(elemento.simbolo), número atómico \(elemento.id)"
        hablar(texto, idioma: idioma)
    }
    
    /// Pronuncia solo el nombre del elemento
    func pronunciarNombre(_ elemento: Elemento, idioma: Idioma = .espanol) {
        let nombre = idioma == .espanol ? elemento.nombreES : elemento.nombreEN
        hablar(nombre, idioma: idioma)
    }
    
    /// Pronuncia solo el símbolo del elemento
    func pronunciarSimbolo(_ elemento: Elemento) {
        hablar(elemento.simbolo, idioma: .espanol, deletrear: true)
    }
    
    /// Pronuncia propiedades del elemento
    func pronunciarPropiedades(_ elemento: Elemento, idioma: Idioma = .espanol) {
        var texto = ""
        
        if idioma == .espanol {
            texto = "\(elemento.nombreES). "
            texto += "Familia: \(elemento.familia.rawValue). "
            texto += "Estado: \(elemento.estado25C.rawValue). "
            
            if let masa = elemento.masaAtomica {
                texto += "Masa atómica: \(String(format: "%.2f", masa)) unidades. "
            }
        } else {
            texto = "\(elemento.nombreEN). "
            // Agregar versión en inglés aquí
        }
        
        hablar(texto, idioma: idioma)
    }
    
    /// Función genérica para hablar texto
    func hablar(_ texto: String, idioma: Idioma = .espanol, velocidad: Float? = nil, deletrear: Bool = false) {
        // Detener cualquier reproducción actual
        detener()
        
        let utterance = AVSpeechUtterance(string: texto)
        
        // Configurar idioma
        let codigoIdioma = idioma == .espanol ? "es-MX" : "en-US"
        utterance.voice = AVSpeechSynthesisVoice(language: codigoIdioma)
        
        // Configurar velocidad
        utterance.rate = velocidad ?? currentRate
        
        // Si se debe deletrear (útil para símbolos)
        if deletrear {
            utterance.rate = currentRate * 0.7 // Más lento para deletrear
        }
        
        // Volumen y tono
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
        isPlaying = true
    }
    
    /// Pausa la reproducción
    func pausar() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            isPlaying = false
        }
    }
    
    /// Continúa la reproducción pausada
    func continuar() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            isPlaying = true
        }
    }
    
    /// Detiene completamente la reproducción
    func detener() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
            currentUtterance = nil
        }
    }
    
    /// Cambia la velocidad de reproducción
    func cambiarVelocidad(_ nuevaVelocidad: Float) {
        currentRate = max(AVSpeechUtteranceMinimumSpeechRate, min(nuevaVelocidad, AVSpeechUtteranceMaximumSpeechRate))
    }
    
    /// Verifica si hay voces disponibles para un idioma
    func hayVocesDisponibles(para idioma: Idioma) -> Bool {
        let codigoIdioma = idioma == .espanol ? "es" : "en"
        return AVSpeechSynthesisVoice.speechVoices().contains { $0.language.hasPrefix(codigoIdioma) }
    }
    
    /// Lista las voces disponibles para un idioma
    func vocesDisponibles(para idioma: Idioma) -> [AVSpeechSynthesisVoice] {
        let codigoIdioma = idioma == .espanol ? "es" : "en"
        return AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(codigoIdioma) }
    }
    
    // MARK: - New speak methods
    
    @objc func speak(_ text: String) {
        hablar(text, idioma: .espanol)
    }
    
    func speak(_ text: String, language: String) {
        let idioma: Idioma
        if language.lowercased().hasPrefix("es") {
            idioma = .espanol
        } else {
            idioma = .ingles
        }
        hablar(text, idioma: idioma)
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TTSManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
            currentUtterance = nil
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
            currentUtterance = nil
        }
    }
}

// MARK: - Helpers
extension TTSManager {
    /// Convierte velocidad de configuración (0.5-2.0) a velocidad AVSpeech
    static func convertirVelocidadDeConfig(_ velocidadConfig: Double) -> Float {
        let min = AVSpeechUtteranceMinimumSpeechRate
        let max = AVSpeechUtteranceMaximumSpeechRate
        let normal = AVSpeechUtteranceDefaultSpeechRate
        
        // Mapear 0.5-2.0 a rango de AVSpeech
        let factor = Float(velocidadConfig)
        if factor < 1.0 {
            return min + (normal - min) * factor
        } else {
            return normal + (max - normal) * (factor - 1.0)
        }
    }
}
