//
//  GamesHubView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - GamesHubView
struct GamesHubView: View {
    @State private var selectedGame: TipoJuego?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(TipoJuego.allCases, id: \.self) { juego in
                    Button {
                        selectedGame = juego
                    } label: {
                        GameRowView(tipoJuego: juego)
                    }
                    .accessibleButton(
                        label: juego.nombre,
                        hint: juego.descripcion
                    )
                }
            }
            .navigationTitle("Juegos")
            .sheet(item: $selectedGame) { juego in
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
