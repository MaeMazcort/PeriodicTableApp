//
//  Constants.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - Información de la App
    static let appName = "Tabla Periódica"
    static let appVersion = "1.0.0"
    static let bundleIdentifier = "com.ninamazadiego.periodictable"
    
    // MARK: - URLs y Enlaces
    enum URLs {
        static let supportEmail = "support@example.com"
        static let privacyPolicy = "https://example.com/privacy"
        static let termsOfService = "https://example.com/terms"
    }
    
    // MARK: - Configuración de Accesibilidad
    enum Accessibility {
        static let minimumTouchTarget: CGFloat = 44
        static let preferredTouchTarget: CGFloat = 48
        static let minimumFontSize: CGFloat = 17
        static let maximumFontSize: CGFloat = 34
        
        static let contrastRatioAA: Double = 4.5
        static let contrastRatioAAA: Double = 7.0
        
        static let defaultAnimationDuration: Double = 0.3
        static let reducedAnimationDuration: Double = 0.15
    }
    
    // MARK: - Configuración de Juegos
    enum Games {
        static let defaultQuizTime = 30 // segundos
        static let flashcardsPerSession = 10
        static let minimumCorrectForMastery = 3
        static let masteryThreshold = 0.8 // 80%
        
        // Repetición espaciada
        static let initialInterval: TimeInterval = 24 * 60 * 60 // 1 día
        static let easyInterval: TimeInterval = 4 * 24 * 60 * 60 // 4 días
        static let goodInterval: TimeInterval = 7 * 24 * 60 * 60 // 7 días
        static let hardInterval: TimeInterval = 14 * 24 * 60 * 60 // 14 días
    }
    
    // MARK: - Configuración de TTS
    enum TTS {
        static let defaultRate: Float = 0.5
        static let minimumRate: Float = 0.3
        static let maximumRate: Float = 0.7
        static let defaultVolume: Float = 1.0
        
        static let defaultVoiceES = "es-MX"
        static let defaultVoiceEN = "en-US"
    }
    
    // MARK: - Límites y Validaciones
    enum Limits {
        static let maxFavorites = 118 // Todos los elementos
        static let maxSearchResults = 50
        static let maxRecentElements = 10
        static let maxGameSessionsStored = 100
    }
    
    // MARK: - Claves de UserDefaults
    enum UserDefaultsKeys {
        static let userProgress = "user_progress"
        static let userSettings = "user_settings"
        static let onboardingCompleted = "onboarding_completed"
        static let lastAppVersion = "last_app_version"
        static let firstLaunchDate = "first_launch_date"
    }
    
    // MARK: - Notificaciones
    enum Notifications {
        static let settingsChanged = "settingsChanged"
        static let progressUpdated = "progressUpdated"
        static let languageChanged = "languageChanged"
        static let themeChanged = "themeChanged"
    }
    
    // MARK: - Animaciones
    enum Animations {
        static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeInOut = Animation.easeInOut(duration: 0.3)
        static let gentle = Animation.easeInOut(duration: 0.2)
    }
    
    // MARK: - Diseño
    enum Design {
        static let cornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
        
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.1
    }
}

// MARK: - Extensiones de SizeCategory
extension DynamicTypeSize {
    var isAccessibilityCategory: Bool {
        switch self {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return true
        default:
            return false
        }
    }
}

// MARK: - Extensiones de Date
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func daysAgo() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: Date())
        return components.day ?? 0
    }
}

// MARK: - Extensiones de String
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Helpers de Debug
#if DEBUG
enum DebugHelper {
    static func printJSON<T: Encodable>(_ object: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(object),
           let string = String(data: data, encoding: .utf8) {
            print(string)
        }
    }
    
    static func measure(title: String = "", operation: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        operation()
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("⏱ \(title): \(String(format: "%.4f", diff))s")
    }
}
#endif
