//
//  GameViewPlaceholder.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct GameViewPlaceholder: View {
    let tipoJuego: TipoJuego
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: tipoJuego.icono)
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text(tipoJuego.nombre)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(tipoJuego.descripcion)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("(En desarrollo)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle(tipoJuego.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GameViewPlaceholder(tipoJuego: .flashcards)
}
