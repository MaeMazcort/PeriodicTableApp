//
//  MainTabViews.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

// MARK: - ProgressView (Estadísticas)
struct ProgressView: View {
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Estadísticas Generales") {
                    StatRow(
                        icon: "flame.fill",
                        title: "Racha actual",
                        value: "\(progressManager.progreso.rachaActual) días",
                        color: .orange
                    )
                    
                    StatRow(
                        icon: "trophy.fill",
                        title: "Mejor racha",
                        value: "\(progressManager.progreso.mejorRacha) días",
                        color: .yellow
                    )
                    
                    StatRow(
                        icon: "checkmark.circle.fill",
                        title: "Precisión",
                        value: String(format: "%.1f%%", progressManager.progreso.porcentajePrecision),
                        color: .green
                    )
                    
                    StatRow(
                        icon: "clock.fill",
                        title: "Tiempo de estudio",
                        value: "\(progressManager.progreso.tiempoTotalEstudioMinutos) min",
                        color: .blue
                    )
                }
                
                Section("Elementos") {
                    StatRow(
                        icon: "star.fill",
                        title: "Favoritos",
                        value: "\(progressManager.progreso.elementosFavoritos.count)",
                        color: .yellow
                    )
                    
                    StatRow(
                        icon: "checkmark.circle.fill",
                        title: "Dominados",
                        value: "\(elementosDominados)",
                        color: .green
                    )
                }
                
                Section("Sesiones de Juego") {
                    StatRow(
                        icon: "gamecontroller.fill",
                        title: "Total de sesiones",
                        value: "\(progressManager.progreso.sesionesJuego.count)",
                        color: .purple
                    )
                }
            }
            .navigationTitle("Progreso")
        }
    }
    
    private var elementosDominados: Int {
        progressManager.progreso.elementosEstudiados.values.filter { $0.nivelDominio == .dominado }.count
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .accessibleGroup(label: "\(title): \(value)")
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var ttsManager: TTSManager
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Idioma") {
                    Picker("Idioma", selection: $progressManager.settings.idioma) {
                        ForEach(Idioma.allCases, id: \.self) { idioma in
                            Text(idioma.nombre).tag(idioma)
                        }
                    }
                    .onChange(of: progressManager.settings.idioma) { _, _ in
                        progressManager.guardarSettings()
                    }
                }
                
                Section("Apariencia") {
                    Picker("Tema", selection: $progressManager.settings.temaVisual) {
                        ForEach(TemaVisual.allCases, id: \.self) { tema in
                            Label(tema.nombre, systemImage: tema.icono).tag(tema)
                        }
                    }
                    
                    Toggle("Alto Contraste", isOn: $progressManager.settings.usarAltoContraste)
                    
                    Toggle("Reducir Movimiento", isOn: $progressManager.settings.reducirMovimiento)
                }
                .onChange(of: progressManager.settings.temaVisual) { _, _ in
                    progressManager.guardarSettings()
                }
                .onChange(of: progressManager.settings.usarAltoContraste) { _, _ in
                    progressManager.guardarSettings()
                }
                
                Section("Audio") {
                    HStack {
                        Text("Velocidad de voz")
                        Spacer()
                        Text(String(format: "%.1fx", progressManager.settings.velocidadTTS))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: $progressManager.settings.velocidadTTS,
                        in: 0.5...2.0,
                        step: 0.1
                    )
                    .accessibilityLabel("Velocidad de lectura")
                    .accessibilityValue("\(String(format: "%.1f", progressManager.settings.velocidadTTS)) veces")
                    
                    Toggle("Sonidos", isOn: $progressManager.settings.habilitarSonidos)
                    Toggle("Hápticos", isOn: $progressManager.settings.habilitarHaptics)
                }
                .onChange(of: progressManager.settings.velocidadTTS) { _, newValue in
                    ttsManager.cambiarVelocidad(TTSManager.convertirVelocidadDeConfig(newValue))
                    progressManager.guardarSettings()
                }
                
                Section("Datos") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Restablecer Progreso", systemImage: "trash")
                    }
                }
                
                Section("Acerca de") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .alert("¿Restablecer Progreso?", isPresented: $showResetAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Restablecer", role: .destructive) {
                    progressManager.resetearProgreso()
                }
            } message: {
                Text("Se eliminarán todos tus datos de progreso. Esta acción no se puede deshacer.")
            }
        }
    }
}

// MARK: - Previews
#Preview("Progreso") {
    ProgressView()
        .environmentObject(ProgressManager.shared)
}

#Preview("Ajustes") {
    SettingsView()
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
