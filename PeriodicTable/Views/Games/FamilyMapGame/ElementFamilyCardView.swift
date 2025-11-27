//
//  ElementFamiliyCardView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Card displaying element to classify
//

import SwiftUI

private extension Color {
    static let successGreen = Color(red: 0x51/255.0, green: 0xcf/255.0, blue: 0x66/255.0)
    static let errorRed = Color(red: 0xff/255.0, green: 0x6b/255.0, blue: 0x6b/255.0)
    static let gradientStart = Color(red: 0x66/255.0, green: 0x7e/255.0, blue: 0xea/255.0)
    static let gradientEnd = Color(red: 0x76/255.0, green: 0x4b/255.0, blue: 0xa2/255.0)
}

struct ElementFamilyCardView: View {
    let element: FamilyMapGameElement
    let isClassified: Bool
    let isCorrect: Bool
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThickMaterial)
                .overlay {
                    if isClassified {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                (isCorrect ? Color.successGreen : Color.errorRed).opacity(0.6),
                                lineWidth: 3
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                }
                .shadow(
                    color: isClassified
                    ? (isCorrect ? Color.successGreen : Color.errorRed).opacity(0.3)
                    : .black.opacity(0.12),
                    radius: isClassified ? 20 : 24,
                    x: 0,
                    y: 12
                )
            
            VStack(spacing: 20) {
                // Element symbol - Large and prominent
                if isClassified {
                    Text(element.symbol)
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(isCorrect ? Color.successGreen : Color.errorRed)
                } else {
                    Text(element.symbol)
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.gradientStart, Color.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Element name
                Text(element.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                
                // Classification status icon
                if isClassified {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                        
                        Text(isCorrect ? "¡Correcto!" : "Incorrecto")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(isCorrect ? Color.successGreen : Color.errorRed)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        (isCorrect ? Color.successGreen : Color.errorRed).opacity(0.15),
                        in: Capsule()
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                    // Show correct family if wrong
                    if !isCorrect {
                        Text("Es: \(element.correctFamily.shortName)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }
                } else {
                    // Instruction text
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Selecciona su familia química")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
            }
        }
        .onChange(of: isClassified) { newValue in
            if newValue {
                // Pulse animation when classified
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.05
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.15)) {
                    scale = 1.0
                }
            }
        }
    }
}

// MARK: - Preview
struct ElementFamilyCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.gradientStart.opacity(0.12),
                    Color.gradientEnd.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                ElementFamilyCardView(
                    element: FamilyMapGameElement(
                        id: 1,
                        symbol: "H",
                        name: "Hidrógeno",
                        correctFamily: .noMetales
                    ),
                    isClassified: false,
                    isCorrect: false
                )
                .frame(height: 280)

                ElementFamilyCardView(
                    element: FamilyMapGameElement(
                        id: 1,
                        symbol: "H",
                        name: "Hidrógeno",
                        correctFamily: .noMetales
                    ),
                    isClassified: true,
                    isCorrect: true
                )
                .frame(height: 280)
            }
            .padding()
        }
    }
}
