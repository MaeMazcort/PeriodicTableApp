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
    @State private var showLanthanides = true
    @State private var showActinides = true
    
    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(spacing: 8) {
                    // Main periodic table (periods 1-7, groups 1-18)
                    mainPeriodicTable
                    
                    // Separator for lanthanides and actinides
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Lanthanides (period 6, elements 57-71)
                    if showLanthanides {
                        lanthanidesSeries
                    }
                    
                    // Actinides (period 7, elements 89-103)
                    if showActinides {
                        actinidesSeries
                    }
                }
                .padding()
                .scaleEffect(scale)
            }
            .navigationTitle("Tabla Periódica")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Filtrar por familia") {
                            ForEach(FamiliaElemento.allCases, id: \.self) { familia in
                                Button(familia.rawValue) {
                                    filterByFamily = filterByFamily == familia ? nil : familia
                                }
                            }
                        }
                        
                        Divider()
                        
                        Section("Mostrar/Ocultar") {
                            Toggle("Lantánidos", isOn: $showLanthanides)
                            Toggle("Actínidos", isOn: $showActinides)
                        }
                        
                        Divider()
                        
                        Button("Mostrar todos") {
                            filterByFamily = nil
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibleButton(label: "Filtros y opciones")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            withAnimation {
                                scale = min(scale + 0.1, 2.0)
                            }
                        } label: {
                            Label("Acercar", systemImage: "plus.magnifyingglass")
                        }
                        
                        Button {
                            withAnimation {
                                scale = max(scale - 0.1, 0.5)
                            }
                        } label: {
                            Label("Alejar", systemImage: "minus.magnifyingglass")
                        }
                        
                        Button {
                            withAnimation {
                                scale = 1.0
                            }
                        } label: {
                            Label("Restablecer", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibleButton(label: "Zoom")
                }
            }
            .sheet(item: $selectedElement) { elemento in
                ElementDetailView(elemento: elemento)
            }
        }
    }
    
    // MARK: - Main Periodic Table
    
    private var mainPeriodicTable: some View {
        VStack(spacing: 2) {
            ForEach(1...7, id: \.self) { period in
                HStack(spacing: 2) {
                    ForEach(1...18, id: \.self) { group in
                        elementCell(period: period, group: group)
                    }
                }
            }
        }
    }
    
    private func elementCell(period: Int, group: Int) -> some View {
        Group {
            if let elemento = findElement(period: period, group: group) {
                if shouldShowElement(elemento) {
                    ElementCardView(elemento: elemento)
                        .frame(width: 55, height: 55)
                        .onTapGesture {
                            selectedElement = elemento
                            HapticManager.impact(.light)
                        }
                } else {
                    Color.clear
                        .frame(width: 55, height: 55)
                }
            } else {
                // Empty cell for gaps in the table
                if shouldShowEmptyCell(period: period, group: group) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 55, height: 55)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    Color.clear
                        .frame(width: 55, height: 55)
                }
            }
        }
    }
    
    // MARK: - Lanthanides Series
    
    private var lanthanidesSeries: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Lantánidos")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                Spacer()
            }
            
            HStack(spacing: 2) {
                // Elements 57-71 (La to Lu)
                ForEach(57...71, id: \.self) { atomicNumber in
                    if let elemento = dataManager.buscarElemento(porID: atomicNumber) {
                        if shouldShowElement(elemento) {
                            ElementCardView(elemento: elemento)
                                .frame(width: 55, height: 55)
                                .onTapGesture {
                                    selectedElement = elemento
                                    HapticManager.impact(.light)
                                }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actinides Series
    
    private var actinidesSeries: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Actínidos")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                Spacer()
            }
            
            HStack(spacing: 2) {
                // Elements 89-103 (Ac to Lr)
                ForEach(89...103, id: \.self) { atomicNumber in
                    if let elemento = dataManager.buscarElemento(porID: atomicNumber) {
                        if shouldShowElement(elemento) {
                            ElementCardView(elemento: elemento)
                                .frame(width: 55, height: 55)
                                .onTapGesture {
                                    selectedElement = elemento
                                    HapticManager.impact(.light)
                                }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func findElement(period: Int, group: Int) -> Elemento? {
        // Skip lanthanides and actinides in main table
        return dataManager.elementos.first { elemento in
            elemento.periodo == period && 
            elemento.grupo == group &&
            !(elemento.id >= 57 && elemento.id <= 71) && // Skip lanthanides
            !(elemento.id >= 89 && elemento.id <= 103)   // Skip actinides
        }
    }
    
    private func shouldShowElement(_ elemento: Elemento) -> Bool {
        if let familia = filterByFamily {
            return elemento.familia == familia
        }
        return true
    }
    
    private func shouldShowEmptyCell(period: Int, group: Int) -> Bool {
        // Show placeholder for lanthanides and actinides in main table
        if period == 6 && group == 3 {
            return true // Lanthanides placeholder
        }
        if period == 7 && group == 3 {
            return true // Actinides placeholder
        }
        return false
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
