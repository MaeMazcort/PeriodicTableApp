//
//  MainTabViews.swift
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

// MARK: - SearchView
struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedFilter: FiltroElemento = .todos
    
    var body: some View {
        NavigationStack {
            VStack {
                // Barra de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar elemento...", text: $searchText)
                        .textFieldStyle(.plain)
                        .accessibilityLabel("Campo de búsqueda")
                        .accessibilityHint("Escribe el nombre o símbolo de un elemento")
                }
                .padding()
                .background(ColorPalette.Sistema.fondoSecundario)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Filtros rápidos
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FiltroElemento.allCases, id: \.self) { filtro in
                            FilterChip(
                                title: filtro.nombre,
                                isSelected: selectedFilter == filtro
                            ) {
                                selectedFilter = filtro
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Resultados
                List(searchResults) { elemento in
                    NavigationLink(destination: ElementDetailView(elemento: elemento)) {
                        ElementRowView(elemento: elemento)
                    }
                    .accessibleButton(label: "\(elemento.nombreLocalizado), símbolo \(elemento.simbolo)")
                }
                .listStyle(.plain)
            }
            .navigationTitle("Buscar")
        }
    }
    
    private var searchResults: [Elemento] {
        var results = dataManager.elementos
        
        // Aplicar búsqueda de texto
        if !searchText.isEmpty {
            results = results.filter { elemento in
                elemento.nombreES.lowercased().contains(searchText.lowercased()) ||
                elemento.nombreEN.lowercased().contains(searchText.lowercased()) ||
                elemento.simbolo.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Aplicar filtro
        switch selectedFilter {
        case .todos:
            break
        case .metales:
            results = results.filter { $0.esMetal }
        case .noMetales:
            results = results.filter { !$0.esMetal }
        case .gases:
            results = results.filter { $0.estado25C == .gas }
        case .liquidos:
            results = results.filter { $0.estado25C == .liquido }
        case .solidos:
            results = results.filter { $0.estado25C == .solido }
        }
        
        return results
    }
    
    enum FiltroElemento: String, CaseIterable {
        case todos = "Todos"
        case metales = "Metales"
        case noMetales = "No Metales"
        case gases = "Gases"
        case liquidos = "Líquidos"
        case solidos = "Sólidos"
        
        var nombre: String { rawValue }
    }
}

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
                GameViewPlaceholder(tipoJuego: juego)
            }
        }
    }
}

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

// MARK: - Componentes Auxiliares

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : ColorPalette.Sistema.fondoSecundario)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .accessibleButton(
            label: title,
            hint: isSelected ? "Seleccionado" : "Toca para filtrar"
        )
    }
}

// MARK: - Previews
#Preview("Tabla Periódica") {
    PeriodicTableView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}

#Preview("Búsqueda") {
    SearchView()
        .environmentObject(DataManager.shared)
}

#Preview("Juegos") {
    GamesHubView()
}

#Preview("Progreso") {
    ProgressView()
        .environmentObject(ProgressManager.shared)
}

#Preview("Ajustes") {
    SettingsView()
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
