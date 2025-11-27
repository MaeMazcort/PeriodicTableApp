//
//  SearchView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Modern glassmorphism design
//

import SwiftUI

// Local extension for hex colors
private extension Color {
    init(hexString: String, alpha: Double = 1.0) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        let finalAlpha = alpha * Double(a) / 255.0
        self = Color(.sRGB, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: finalAlpha)
    }
}

struct SearchView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedFilter: FiltroElemento = .todos
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Search header
                    searchHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Filter chips
                    filterSection
                        .padding(.top, 16)
                    
                    // Results counter
                    if !searchText.isEmpty || selectedFilter != .todos {
                        resultsCounter
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    
                    // Results list or empty state
                    if searchResults.isEmpty {
                        emptyState
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.12),
                Color(hexString: "764ba2").opacity(0.08),
                Color(hexString: "f093fb").opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Sections
    
    private var searchHeader: some View {
        HStack(spacing: 14) {
            // Search icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.3),
                                Color(hexString: "764ba2").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: "667eea"))
            }
            
            // Search field
            HStack(spacing: 10) {
                TextField("Buscar elemento...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .focused($isSearchFocused)
                    .accessibilityLabel("Campo de búsqueda")
                    .accessibilityHint("Escribe el nombre o símbolo de un elemento")
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThickMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSearchFocused ?
                            Color(hexString: "667eea").opacity(0.5) :
                            Color.white.opacity(0.3),
                        lineWidth: isSearchFocused ? 2 : 1
                    )
            }
            .shadow(color: Color(hexString: "667eea").opacity(isSearchFocused ? 0.2 : 0.1), radius: 12, x: 0, y: 6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearchFocused)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hexString: "667eea"))
                
                Text("Filtrar por")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FiltroElemento.allCases, id: \.self) { filtro in
                        FilterChip(
                            title: filtro.nombre,
                            isSelected: selectedFilter == filtro
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = filtro
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var resultsCounter: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hexString: "51cf66"))
            
            Text("\(searchResults.count) resultado\(searchResults.count == 1 ? "" : "s")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !searchText.isEmpty || selectedFilter != .todos {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        searchText = ""
                        selectedFilter = .todos
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Limpiar")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Color(hexString: "667eea"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hexString: "667eea").opacity(0.12), in: Capsule())
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { elemento in
                    NavigationLink(destination: ElementDetailView(elemento: elemento)) {
                        ModernElementSearchRow(elemento: elemento, searchText: searchText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.2),
                                Color(hexString: "764ba2").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: searchText.isEmpty ? "magnifyingglass" : "exclamationmark.magnifyingglass")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(Color(hexString: "667eea").opacity(0.6))
            }
            
            // Message
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(emptyStateMessage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Suggestions
            if !searchText.isEmpty {
                VStack(spacing: 12) {
                    Text("Sugerencias:")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        SuggestionRow(text: "Verifica la ortografía")
                        SuggestionRow(text: "Prueba con el símbolo (ej: Fe, Au)")
                        SuggestionRow(text: "Busca por nombre en inglés")
                        SuggestionRow(text: "Intenta con otro filtro")
                    }
                    .padding(16)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hexString: "667eea").opacity(0.08))
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThickMaterial)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Computed Properties
    
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
    
    private var emptyStateTitle: String {
        if searchText.isEmpty {
            return "Busca un elemento"
        } else {
            return "Sin resultados"
        }
    }
    
    private var emptyStateMessage: String {
        if searchText.isEmpty {
            return "Escribe el nombre o símbolo de un elemento para comenzar"
        } else {
            return "No encontramos elementos que coincidan con '\(searchText)'"
        }
    }
}

// MARK: - ModernElementSearchRow

struct ModernElementSearchRow: View {
    let elemento: Elemento
    let searchText: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Symbol circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.3),
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text(elemento.simbolo)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(elemento.nombreLocalizado)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("(\(elemento.simbolo))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    // Atomic number badge
                    HStack(spacing: 4) {
                        Image(systemName: "atom")
                            .font(.system(size: 10, weight: .semibold))
                        Text("\(elemento.id)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ColorPalette.colorParaFamilia(elemento.familia), in: Capsule())
                    
                    // Family
                    Text(elemento.familia.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.10),
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15), radius: 12, x: 0, y: 6)
        .accessibleButton(label: "\(elemento.nombreLocalizado), símbolo \(elemento.simbolo)")
    }
}

// MARK: - SuggestionRow

struct SuggestionRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hexString: "ffd43b"))
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Previews
#Preview("Búsqueda") {
    SearchView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
