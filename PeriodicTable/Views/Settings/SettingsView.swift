//
//  SettingsView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

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

#Preview("Ajustes") {
    SettingsView()
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
