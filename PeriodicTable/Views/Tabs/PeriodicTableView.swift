//
//  PeriodicTableView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - PeriodicTableView
struct PeriodicTableView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @State private var selectedElement: Elemento?
    @State private var filterByFamily: FamiliaElemento?
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 4) {
                    // Aquí iría la tabla periódica completa
                    // Por ahora, mostrar lista temporal
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 18), spacing: 4) {
                        ForEach(filteredElements) { elemento in
                            ElementCardView(elemento: elemento)
                                .onTapGesture {
                                    selectedElement = elemento
                                }
                        }
                    }
                    .padding()
                }
                .scaleEffect(scale)
            }
            .navigationTitle("Tabla Periódica")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(FamiliaElemento.allCases, id: \.self) { familia in
                            Button(familia.rawValue) {
                                filterByFamily = filterByFamily == familia ? nil : familia
                            }
                        }
                        Divider()
                        Button("Mostrar todos") {
                            filterByFamily = nil
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibleButton(label: "Filtros")
                }
            }
            .sheet(item: $selectedElement) { elemento in
                ElementDetailView(elemento: elemento)
            }
        }
    }
    
    private var filteredElements: [Elemento] {
        if let familia = filterByFamily {
            return dataManager.elementos.filter { $0.familia == familia }
        }
        return dataManager.elementos
    }
}

// MARK: - Preview
#Preview("Tabla Periódica") {
    PeriodicTableView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
