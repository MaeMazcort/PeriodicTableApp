//
//  ElementOfTheDayCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Modern glassmorphism design
//

import SwiftUI

struct ElementOfTheDayCard: View {
    let elemento: Elemento
    
    @State private var scale: CGFloat = 0.95
    
    var body: some View {
        NavigationLink(destination: ElementDetailView(elemento: elemento)) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Elemento del Día")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(Color(hexString: "ffd43b"))
                        
                        Text("Descubre algo nuevo")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                // Element display
                HStack(spacing: 20) {
                    // Symbol with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ColorPalette.colorParaFamilia(elemento.familia).opacity(0.3),
                                        ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(elemento.simbolo)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(elemento.nombreLocalizado)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "atom")
                                .font(.system(size: 12, weight: .semibold))
                            Text("No. \(elemento.id)")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15), in: Capsule())
                        
                        Text(elemento.familia.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                    }
                    
                    Spacer()
                }
            }
            .padding(24)
            .background {
                ZStack {
                    // Colored background layer for better contrast
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hexString: "667eea").opacity(0.15),
                                    Color(hexString: "764ba2").opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glass material on top
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThickMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
            .shadow(color: Color(hexString: "667eea").opacity(0.25), radius: 24, x: 0, y: 12)
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
            }
        }
        .accessibleButton(
            label: "Elemento del día: \(elemento.nombreLocalizado), símbolo \(elemento.simbolo)",
            hint: "Toca para ver detalles"
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.08),
                Color(hexString: "764ba2").opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ElementOfTheDayCard(
            elemento: Elemento(
                id: 79,
                simbolo: "Au",
                nombreES: "Oro",
                nombreEN: "Gold",
                familia: .metalesTransicion,
                periodo: 6,
                grupo: 11,
                masaAtomica: 196.967,
                estado25C: .solido,
                densidad: 19.3,
                puntoFusionC: 1337.33,
                puntoEbullicionC: 3243,
                configuracionElectronica: "[Xe] 4f14 5d10 6s1",
                electronegatividad: 2.54,
                radioAtomico: 144,
                energiaIonizacion: 890.1,
                usosES: ["Joyería", "Electrónica", "Medicina"],
                usosEN: ["Jewelry", "Electronics", "Medicine"]
            )
        )
        .padding()
    }
}
