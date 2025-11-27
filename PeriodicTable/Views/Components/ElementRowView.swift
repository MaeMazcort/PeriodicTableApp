//
//  ElementRowView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - ElementRowView (para listas)
struct ElementRowView: View {
    let elemento: Elemento
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Círculo con símbolo
            ZStack {
                Circle()
                    .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(elemento.simbolo)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(elemento.nombreLocalizado)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    if progressManager.esFavorito(elemento.id) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack {
                    Text(elemento.familia.rawValue)
                        .font(.caption)
                    
                    Text("•")
                        .font(.caption)
                    
                    Text("Z = \(elemento.id)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Nivel de dominio
            if let nivel = progressManager.estadoAprendizaje(de: elemento.id)?.nivelDominio {
                Image(systemName: nivel.icono)
                    .foregroundColor(ColorPalette.colorParaNivelDominio(nivel))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews
#Preview("Fila de Elemento") {
    ElementRowView(elemento: .ejemploHidrogeno)
        .environmentObject(ProgressManager.shared)
}
