//
//  GamesHubView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - GamesHubView
struct GamesHubView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(TipoJuego.allCases, id: \.self) { juego in
                    NavigationLink(value: juego) {
                        GameRowView(tipoJuego: juego)
                    }
                    .accessibleButton(
                        label: juego.nombre,
                        hint: juego.descripcion
                    )
                }
            }
            .navigationTitle("Juegos")
            .navigationDestination(for: TipoJuego.self) { juego in
                switch juego {
                case .flashcards:
                    FlashcardGameView()
                default:
                    GameViewPlaceholder(tipoJuego: juego)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Juegos") {
    GamesHubView()
}
