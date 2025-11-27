//
//  ElementCardView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - ElementCardView (para la tabla periódica)
struct ElementCardView: View {
    let elemento: Elemento
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: 2) {
            // Número atómico
            Text("\(elemento.id)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Símbolo
            Text(elemento.simbolo)
                .font(sizeCategory.isAccessibilityCategory ? .body : .title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            // Nombre (opcional, depende del espacio)
            if !sizeCategory.isAccessibilityCategory {
                Text(elemento.nombreLocalizado)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(minWidth: 50, minHeight: 50)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    progressManager.esFavorito(elemento.id) ? Color.yellow : Color.clear,
                    lineWidth: 2
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(elemento.nombreLocalizado), símbolo \(elemento.simbolo), número atómico \(elemento.id)")
        .accessibilityHint("Toca para ver detalles del elemento")
    }
}

// MARK: - Previews
#Preview("Tarjeta de Elemento") {
    ElementCardView(elemento: .ejemploHidrogeno)
        .environmentObject(ProgressManager.shared)
}
