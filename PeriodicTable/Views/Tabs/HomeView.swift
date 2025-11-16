//
//  HomeView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Saludo
                    greetingSection
                    
                    // Racha
                    streakCard
                    
                    // Elemento del día
                    elementOfTheDayCard
                    
                    // Accesos rápidos
                    quickActionsSection
                    
                    // Favoritos recientes
                    if !progressManager.progreso.elementosFavoritos.isEmpty {
                        favoritesSection
                    }
                }
                .padding()
            }
            .background(ColorPalette.Sistema.fondo)
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Secciones
    
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.semibold)
                .accessibleHeader(greeting)
            
            Text("Explora la tabla periódica")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var streakCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(progressManager.progreso.rachaActual) días")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Racha actual")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if progressManager.progreso.mejorRacha > progressManager.progreso.rachaActual {
                    Text("Récord: \(progressManager.progreso.mejorRacha) días")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
        .accessibleCard(
            label: "Racha de estudio: \(progressManager.progreso.rachaActual) días consecutivos",
            hint: progressManager.progreso.mejorRacha > progressManager.progreso.rachaActual ?
                "Tu récord es \(progressManager.progreso.mejorRacha) días" : nil
        )
    }
    
    private var elementOfTheDayCard: some View {
        Group {
            if let elementoDelDia = dataManager.elementoAleatorio() {
                ElementOfTheDayCard(elemento: elementoDelDia)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones rápidas")
                .font(.headline)
                .accessibleHeader("Acciones rápidas")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "square.grid.3x3.fill",
                    title: "Explorar Tabla",
                    color: .blue
                ) {
                    // Navegar a tabla
                }
                
                QuickActionButton(
                    icon: "gamecontroller.fill",
                    title: "Jugar",
                    color: .green
                ) {
                    // Navegar a juegos
                }
                
                QuickActionButton(
                    icon: "bolt.fill",
                    title: "Reto Rápido",
                    color: .orange
                ) {
                    // Iniciar reto
                }
                
                QuickActionButton(
                    icon: "magnifyingglass",
                    title: "Buscar",
                    color: .purple
                ) {
                    // Navegar a búsqueda
                }
            }
        }
    }
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tus favoritos")
                .font(.headline)
                .accessibleHeader("Tus elementos favoritos")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(progressManager.progreso.elementosFavoritos.prefix(5)), id: \.self) { elementoID in
                        if let elemento = dataManager.buscarElemento(porID: elementoID) {
                            NavigationLink(destination: ElementDetailView(elemento: elemento)) {
                                ElementMiniCard(elemento: elemento)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Buenos días"
        case 12..<18:
            return "Buenas tardes"
        default:
            return "Buenas noches"
        }
    }
}

// MARK: - Componentes Auxiliares

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorPalette.Sistema.fondoSecundario)
            )
        }
        .accessibleButton(label: title)
    }
}

struct ElementMiniCard: View {
    let elemento: Elemento
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(elemento.simbolo)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Text(elemento.nombreLocalizado)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
        .accessibleButton(label: elemento.nombreLocalizado)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
