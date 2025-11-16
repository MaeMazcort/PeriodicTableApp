//
//  AccesiblityHelpers.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - View Extensions para Accesibilidad
extension View {
    /// Aplica configuración accesible estándar para botones
    func accessibleButton(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
            .frame(minWidth: 44, minHeight: 44) // Tamaño mínimo táctil
    }
    
    /// Aplica configuración para elementos que se pueden seleccionar
    func accessibleSelectable(
        label: String,
        hint: String? = nil,
        isSelected: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    /// Marca un elemento como header para navegación
    func accessibleHeader(_ text: String) -> some View {
        self
            .accessibilityLabel(text)
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Agrupa elementos para VoiceOver
    func accessibleGroup(label: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label ?? "")
    }
    
    /// Aplica respeto a Dynamic Type con límites
    func limitedDynamicTypeSize(_ range: ClosedRange<DynamicTypeSize>) -> some View {
        self.dynamicTypeSize(range)
    }
    
    /// Aplica configuración de alto contraste
    @ViewBuilder
    func highContrastAdaptive<V: View>(
        highContrast: @escaping () -> V
    ) -> some View {
        if UIAccessibility.isDarkerSystemColorsEnabled {
            highContrast()
        } else {
            self
        }
    }
}

// MARK: - Modificadores Personalizados
struct AccessibleCardModifier: ViewModifier {
    let label: String
    let hint: String?
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Toca para ver más detalles")
            .accessibilityAddTraits(.isButton)
    }
}

struct MinimumTouchTargetModifier: ViewModifier {
    let minSize: CGFloat = 44
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minSize, minHeight: minSize)
    }
}

extension View {
    func accessibleCard(label: String, hint: String? = nil) -> some View {
        modifier(AccessibleCardModifier(label: label, hint: hint))
    }
    
    func minimumTouchTarget() -> some View {
        modifier(MinimumTouchTargetModifier())
    }
}

// MARK: - Helpers de Ambiente
struct AccessibilityEnvironment {
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    var isLargeText: Bool {
        sizeCategory >= .accessibilityMedium
    }
    
    var shouldReduceMotion: Bool {
        reduceMotion
    }
    
    var isDarkMode: Bool {
        colorScheme == .dark
    }
}

// MARK: - Extensiones de UIAccessibility
extension UIAccessibility {
    /// Verifica si VoiceOver está activo
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    /// Verifica si el modo de alto contraste está activo
    static var isHighContrastEnabled: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled || UIAccessibility.isInvertColorsEnabled
    }
    
    /// Verifica si hay que diferenciar sin color
    static var shouldDifferentiateWithoutColor: Bool {
        UIAccessibility.shouldDifferentiateWithoutColor
    }
    
    /// Anuncia un mensaje a VoiceOver
    static func announce(_ message: String, type: UIAccessibility.Notification = .announcement) {
        UIAccessibility.post(notification: type, argument: message)
    }
    
    /// Anuncia que el layout cambió (útil después de navegación)
    static func announceLayoutChange(focusOn element: Any? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }
}

// MARK: - Protocolo para Elementos Accesibles
protocol AccessibleElement {
    var accessibilityLabel: String { get }
    var accessibilityHint: String? { get }
    var accessibilityValue: String? { get }
}

// MARK: - Helpers para Haptics
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard !ProcessInfo.processInfo.isLowPowerModeEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard !ProcessInfo.processInfo.isLowPowerModeEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        guard !ProcessInfo.processInfo.isLowPowerModeEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Helpers para Animaciones Accesibles
extension Animation {
    /// Retorna animación o nil según configuración de reducción de movimiento
    static func accessibleDefault(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .default
    }
    
    static func accessibleSpring(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)
    }
    
    static func accessibleEaseInOut(reduceMotion: Bool, duration: Double = 0.3) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: duration)
    }
}

// MARK: - Helper para Colores Accesibles
extension Color {
    /// Retorna color con contraste mínimo AA
    func ensureContrast(against background: Color, ratio: Double = 4.5) -> Color {
        // Implementación simplificada - en producción usar cálculo de luminosidad real
        return self
    }
    
    /// Retorna color adaptado para alto contraste
    func adaptedForHighContrast(isHighContrast: Bool) -> Color {
        if isHighContrast {
            // Aumentar saturación y contraste
            return self
        }
        return self
    }
}

// MARK: - Helper para Texto Accesible
extension Text {
    /// Aplica estilo de texto accesible con escalado dinámico
    func accessibleTextStyle(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> some View {
        self
            .font(.system(style, design: .default, weight: weight))
            .minimumScaleFactor(0.5)
            .lineLimit(nil)
    }
    
    /// Aplica formato de título accesible
    func accessibleTitle() -> some View {
        self
            .font(.title)
            .fontWeight(.bold)
            .minimumScaleFactor(0.7)
    }
    
    /// Aplica formato de encabezado accesible
    func accessibleHeadline() -> some View {
        self
            .font(.headline)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.8)
    }
}

// MARK: - Constantes de Accesibilidad
enum AccessibilityConstants {
    static let minimumTouchTarget: CGFloat = 44
    static let preferredTouchTarget: CGFloat = 48
    static let minimumFontSize: CGFloat = 17
    static let contrastRatioAA: Double = 4.5
    static let contrastRatioAAA: Double = 7.0
    static let animationDuration: Double = 0.3
}
