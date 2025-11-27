//
//  ElementDetailView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - ElementDetailView (vista completa del elemento)
struct ElementDetailView: View {
    let elemento: Elemento
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var ttsManager: TTSManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header con símbolo
                    headerSection
                    
                    // Propiedades básicas
                    basicPropertiesSection
                    
                    // Propiedades físicas
                    if elemento.densidad != nil || elemento.puntoFusionC != nil {
                        physicalPropertiesSection
                    }
                    
                    // Propiedades químicas
                    if elemento.electronegatividad != nil || elemento.configuracionElectronica != nil {
                        chemicalPropertiesSection
                    }
                    
                    // Usos
                    if !elemento.usosLocalizados.isEmpty {
                        usesSection
                    }
                    
                    // Curiosidades
                    if let curiosidades = elemento.curiosidadesES {
                        funFactsSection(curiosidades)
                    }
                }
                .padding()
            }
            .background(ColorPalette.Sistema.fondo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        progressManager.toggleFavorito(elemento.id)
                        HapticManager.impact(.light)
                    } label: {
                        Image(systemName: progressManager.esFavorito(elemento.id) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    .accessibleButton(
                        label: progressManager.esFavorito(elemento.id) ? "Quitar de favoritos" : "Agregar a favoritos"
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibleButton(label: "Cerrar")
                }
            }
            .onAppear {
                progressManager.registrarVistaElemento(elemento.id)
            }
        }
    }
    
    // MARK: - Secciones
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Símbolo grande
            ZStack {
                Circle()
                    .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.2))
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4) {
                    Text(elemento.simbolo)
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("\(elemento.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Nombre
            Text(elemento.nombreLocalizado)
                .font(.title)
                .fontWeight(.bold)
            
            // Familia
            Text(elemento.familia.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Botón de pronunciar
            Button {
                if ttsManager.isPlaying {
                    ttsManager.detener()
                } else {
                    ttsManager.pronunciarElemento(elemento)
                }
            } label: {
                Label(
                    ttsManager.isPlaying ? "Detener" : "Escuchar",
                    systemImage: ttsManager.isPlaying ? "stop.circle.fill" : "speaker.wave.2.fill"
                )
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.accentColor))
            }
            .accessibleButton(
                label: ttsManager.isPlaying ? "Detener pronunciación" : "Escuchar pronunciación del elemento"
            )
        }
    }
    
    private var basicPropertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Propiedades Básicas")
                .font(.headline)
                .accessibleHeader("Propiedades Básicas")
            
            PropertyRow(
                icon: "number",
                label: "Número Atómico",
                value: "\(elemento.id)"
            )
            
            if let masa = elemento.masaAtomica {
                PropertyRow(
                    icon: "scalemass",
                    label: "Masa Atómica",
                    value: String(format: "%.3f u", masa)
                )
            }
            
            PropertyRow(
                icon: "chart.bar.fill",
                label: "Periodo",
                value: "\(elemento.periodo)"
            )
            
            if let grupo = elemento.grupo {
                PropertyRow(
                    icon: "square.grid.3x3",
                    label: "Grupo",
                    value: "\(grupo)"
                )
            }
            
            PropertyRow(
                icon: elemento.estado25C.icono,
                label: "Estado (25°C)",
                value: elemento.estado25C.rawValue
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
    }
    
    private var physicalPropertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Propiedades Físicas")
                .font(.headline)
                .accessibleHeader("Propiedades Físicas")
            
            if let densidad = elemento.densidad {
                PropertyRow(
                    icon: "cube",
                    label: "Densidad",
                    value: String(format: "%.3f g/cm³", densidad)
                )
            }
            
            if let fusion = elemento.puntoFusionC {
                PropertyRow(
                    icon: "thermometer.low",
                    label: "Punto de Fusión",
                    value: String(format: "%.1f °C", fusion)
                )
            }
            
            if let ebullicion = elemento.puntoEbullicionC {
                PropertyRow(
                    icon: "thermometer.high",
                    label: "Punto de Ebullición",
                    value: String(format: "%.1f °C", ebullicion)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
    }
    
    private var chemicalPropertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Propiedades Químicas")
                .font(.headline)
                .accessibleHeader("Propiedades Químicas")
            
            if let config = elemento.configuracionElectronica {
                PropertyRow(
                    icon: "atom",
                    label: "Configuración Electrónica",
                    value: config
                )
            }
            
            if let electroneg = elemento.electronegatividad {
                PropertyRow(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Electronegatividad",
                    value: String(format: "%.2f (Pauling)", electroneg)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
    }
    
    private var usesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Usos Comunes")
                .font(.headline)
                .accessibleHeader("Usos Comunes")
            
            ForEach(elemento.usosLocalizados, id: \.self) { uso in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text(uso)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
    }
    
    private func funFactsSection(_ curiosidades: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("¿Sabías que...?")
                    .font(.headline)
            }
            .accessibleHeader("Curiosidad")
            
            Text(curiosidades)
                .font(.body)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.Sistema.fondoSecundario)
        )
    }
}

// MARK: - PropertyRow
struct PropertyRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(label)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .accessibleGroup(label: "\(label): \(value)")
    }
}

// MARK: - Previews
#Preview("Detalle de Elemento") {
    ElementDetailView(elemento: .ejemploHidrogeno)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
