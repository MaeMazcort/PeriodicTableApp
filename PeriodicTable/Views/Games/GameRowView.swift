//
//  GameRowView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct GameRowView: View {
    let tipoJuego: TipoJuego
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: tipoJuego.icono)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tipoJuego.nombre)
                    .font(.headline)
                
                Text(tipoJuego.descripcion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text("\(tipoJuego.duracionEstimadaMinutos) min")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    List {
        GameRowView(tipoJuego: .flashcards)
        GameRowView(tipoJuego: .quiz)
        GameRowView(tipoJuego: .bingo)
    }
}
