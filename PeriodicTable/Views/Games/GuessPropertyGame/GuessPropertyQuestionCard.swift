//
//  GuessPropertyQuestionCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Question card with property input
//

import SwiftUI

struct GuessPropertyQuestionCard: View {
    let question: GuessPropertyQuestion
    @Binding var guessValue: Double
    let onSubmit: () -> Void
    let isReviewing: Bool
    
    @State private var scale: CGFloat = 0.95
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Element display
            elementSection
            
            // Property to guess
            propertySection
            
            if !isReviewing {
                // Input section
                inputSection
                
                // Submit button
                submitButton
            }
        }
        .padding(24)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 12)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
            }
        }
    }
    
    // MARK: - Element Section
    private var elementSection: some View {
        VStack(spacing: 12) {
            // Element symbol
            Text(question.elemento.simbolo)
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Element name
            Text(question.elemento.nombreES)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.primary)
            
            // Atomic number badge
            HStack(spacing: 6) {
                Image(systemName: "atom")
                    .font(.system(size: 12, weight: .semibold))
                
                Text("No. \(question.elemento.id)")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1), in: Capsule())
        }
    }
    
    // MARK: - Property Section
    private var propertySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: question.propertyType.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: question.propertyType.color))
                
                Text("Adivina: \(question.propertyType.rawValue)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            Text(question.propertyType.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(16)
        .background(Color(hex: question.propertyType.color).opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: question.propertyType.color).opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 16) {
            // Value display
            HStack(spacing: 8) {
                Text(formatValue(guessValue))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color(hex: question.propertyType.color))
                    .contentTransition(.numericText())
                    .monospacedDigit()
                
                if !question.propertyType.unit.isEmpty {
                    Text(question.propertyType.unit)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 60)
            
            // Slider
            VStack(spacing: 8) {
                Slider(
                    value: $guessValue,
                    in: question.propertyType.minValue...question.propertyType.maxValue,
                    step: question.propertyType.step
                )
                .tint(Color(hex: question.propertyType.color))
                
                HStack {
                    Text(formatValue(question.propertyType.minValue))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(formatValue(question.propertyType.maxValue))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: question.propertyType.color).opacity(0.3), lineWidth: 1.5)
        }
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            generateHaptic(style: .medium)
            onSubmit()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Confirmar Estimación")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
    
    private func formatValue(_ value: Double) -> String {
        switch question.propertyType {
        case .masaAtomica:
            return String(format: "%.1f", value)
        case .puntoFusion, .puntoEbullicion:
            return String(format: "%.0f", value)
        case .densidad:
            return String(format: "%.2f", value)
        case .electronegatividad:
            return String(format: "%.2f", value)
        case .radioAtomico:
            return String(format: "%.0f", value)
        case .energiaIonizacion:
            return String(format: "%.0f", value)
        }
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
struct GuessPropertyQuestionCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.12),
                    Color(hex: "764ba2").opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GuessPropertyQuestionCard(
                question: GuessPropertyQuestion(
                    elemento: Elemento(id: 1, simbolo: "H", nombreES: "Hidrógeno", nombreEN: "Hydrogen", familia: .noMetales, periodo: 1, grupo: 1, masaAtomica: 1.008, estado25C: .gas, densidad: 0.00008988, puntoFusionC: -259.16, puntoEbullicionC: -252.87, configuracionElectronica: "1s¹", electronegatividad: 2.20, radioAtomico: 53, energiaIonizacion: 1312, usosES: [], usosEN: [], curiosidadesES: "", curiosidadesEN: "", seguridadES: nil, seguridadEN: nil),
                    propertyType: .masaAtomica
                ),
                guessValue: .constant(10.0),
                onSubmit: {},
                isReviewing: false
            )
            .padding()
        }
    }
}

