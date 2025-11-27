//
//  GuessPropertyAnswerView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Answer reveal with visual comparison
//

import SwiftUI

struct GuessPropertyAnswerView: View {
    let question: GuessPropertyQuestion
    let onNext: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.9
    
    private var score: Int {
        question.calculateScore()
    }
    
    private var accuracy: AccuracyLevel {
        question.accuracyLevel
    }
    
    var body: some View {
        VStack(spacing: 28) {
            // Accuracy badge
            accuracyBadge
            
            // Element info
            elementInfo
            
            // Comparison view
            comparisonView
            
            // Score display
            scoreDisplay
            
            // Next button
            nextButton
        }
        .padding(24)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color(hex: accuracy.color).opacity(0.5), lineWidth: 3)
        }
        .shadow(color: Color(hex: accuracy.color).opacity(0.3), radius: 24, x: 0, y: 12)
        .scaleEffect(scale)
        .opacity(showContent ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
                scale = 1.0
            }
        }
    }
    
    // MARK: - Accuracy Badge
    private var accuracyBadge: some View {
        VStack(spacing: 8) {
            Text(accuracy.emoji)
                .font(.system(size: 56))
            
            Text(accuracy.message)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(hex: accuracy.color))
        }
    }
    
    // MARK: - Element Info
    private var elementInfo: some View {
        HStack(spacing: 12) {
            Text(question.elemento.simbolo)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(hex: question.propertyType.color))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(question.elemento.nombreES)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(question.propertyType.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(hex: question.propertyType.color).opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - Comparison View
    private var comparisonView: some View {
        VStack(spacing: 20) {
            // Your guess
            comparisonRow(
                label: "Tu estimación",
                value: question.userGuess ?? 0,
                icon: "person.fill",
                color: Color(hex: "667eea"),
                isGuess: true
            )
            
            // Divider with vs
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("VS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Correct answer
            comparisonRow(
                label: "Valor real",
                value: question.correctValue,
                icon: "checkmark.seal.fill",
                color: Color(hex: accuracy.color),
                isGuess: false
            )
            
            // Difference display
            differenceDisplay
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
    
    private func comparisonRow(label: String, value: Double, icon: String, color: Color, isGuess: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 6) {
                    Text(formatValue(value))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(color)
                        .monospacedDigit()
                    
                    if !question.propertyType.unit.isEmpty {
                        Text(question.propertyType.unit)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var differenceDisplay: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.left.and.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: accuracy.color))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Diferencia:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text(String(format: "±%.1f%%", question.percentError))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: accuracy.color))
                    .monospacedDigit()
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color(hex: accuracy.color).opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: accuracy.color).opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Score Display
    private var scoreDisplay: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(hex: "ffd43b"))
            
            Text("+\(score) puntos")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Spacer()
        }
        .padding(16)
        .background(Color(hex: "ffd43b").opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "ffd43b").opacity(0.4), lineWidth: 1.5)
        }
    }
    
    // MARK: - Next Button
    private var nextButton: some View {
        Button {
            generateHaptic(style: .light)
            onNext()
        } label: {
            HStack(spacing: 10) {
                Text("Continuar")
                    .font(.system(size: 18, weight: .bold))
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
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
struct GuessPropertyAnswerView_Previews: PreviewProvider {
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
            
            ScrollView {
                GuessPropertyAnswerView(
                    question: {
                        var q = GuessPropertyQuestion(
                            elemento: Elemento(id: 26, simbolo: "Fe", nombreES: "Hierro", nombreEN: "Iron", familia: .metalesTransicion, periodo: 4, grupo: 8, masaAtomica: 55.845, estado25C: .solido, densidad: 7.874, puntoFusionC: 1538, puntoEbullicionC: 2862, configuracionElectronica: "[Ar] 3d⁶ 4s²", electronegatividad: 1.83, radioAtomico: 126, energiaIonizacion: 762, usosES: [], usosEN: [], curiosidadesES: "", curiosidadesEN: "", seguridadES: nil, seguridadEN: nil),
                            propertyType: .masaAtomica
                        )
                        q.userGuess = 60.0
                        q.isAnswered = true
                        return q
                    }(),
                    onNext: {}
                )
                .padding()
            }
        }
    }
}
