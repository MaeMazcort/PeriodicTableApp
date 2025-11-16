//
//  ElementOfTheDayCard.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct ElementOfTheDayCard: View {
    let elemento: Elemento
    
    var body: some View {
        NavigationLink(destination: ElementDetailView(elemento: elemento)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Elemento del día")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "sparkles")
                }
                .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    // Símbolo
                    ZStack {
                        Circle()
                            .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text(elemento.simbolo)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(elemento.nombreLocalizado)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(elemento.familia.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorPalette.Sistema.fondoSecundario)
            )
        }
        .accessibleButton(
            label: "Elemento del día: \(elemento.nombreLocalizado), símbolo \(elemento.simbolo)",
            hint: "Toca para ver detalles"
        )
    }
}

// MARK: - Preview
#Preview {
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
