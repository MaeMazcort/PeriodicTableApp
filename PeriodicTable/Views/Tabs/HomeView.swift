//
//  HomeView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Modern glassmorphism design
//

import SwiftUI

// Local, unambiguous hex Color initializer to avoid collisions
private extension Color {
    init(hexString: String, alpha: Double = 1.0) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        let finalAlpha = alpha * Double(a) / 255.0
        self = Color(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: finalAlpha
        )
    }
}

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Binding var selectedTab: ContentView.Tab
    
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    @State private var isShowingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Greeting
                        greetingSection
                            .padding(.top, 8)
                        
                        // Streak card
                        streakCard
                        
                        // Element of the day
                        elementOfTheDayCard
                        
                        // Quick actions
                        quickActionsSection
                        
                        // Favorites
                        if !progressManager.progreso.elementosFavoritos.isEmpty {
                            favoritesSection
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        generateHaptic()
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.15),
                Color(hexString: "764ba2").opacity(0.12),
                Color(hexString: "f093fb").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Sections
    
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(greetingEmoji)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Explora la tabla periódica")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var streakCard: some View {
        HStack(spacing: 20) {
            // Flame icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hexString: "ff6b6b").opacity(0.2), Color(hexString: "ffa94d").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hexString: "ff6b6b"), Color(hexString: "ffa94d")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(progressManager.progreso.rachaActual) días")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                Text("Racha de estudio")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                
                if progressManager.progreso.mejorRacha > progressManager.progreso.rachaActual {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Récord: \(progressManager.progreso.mejorRacha) días")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hexString: "ffd43b"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hexString: "ffd43b").opacity(0.15), in: Capsule())
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            ZStack {
                // Colored background layer
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "ff6b6b").opacity(0.12),
                                Color(hexString: "ffa94d").opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass material on top
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .shadow(color: Color(hexString: "ff6b6b").opacity(0.25), radius: 24, x: 0, y: 12)
        .scaleEffect(scale)
        .opacity(opacity)
        .modifier(
            AccessibleCardModifier(
                label: "Racha de estudio: \(progressManager.progreso.rachaActual) días consecutivos",
                hint: progressManager.progreso.mejorRacha > progressManager.progreso.rachaActual ?
                    "Tu récord es \(progressManager.progreso.mejorRacha) días" : nil
            )
        )
    }
    
    private var elementOfTheDayCard: some View {
        Group {
            if let elementoDelDia = dataManager.elementoAleatorio() {
                ModernElementOfTheDayCard(elemento: elementoDelDia)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hexString: "667eea"))
                
                Text("Acceso Rápido")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 14) {
                ModernQuickActionButton(
                    icon: "square.grid.3x3.fill",
                    title: "Explorar",
                    gradient: [Color(hexString: "667eea"), Color(hexString: "764ba2")]
                ) {
                    generateHaptic()
                    selectedTab = .table
                }
                
                ModernQuickActionButton(
                    icon: "gamecontroller.fill",
                    title: "Jugar",
                    gradient: [Color(hexString: "51cf66"), Color(hexString: "38d9a9")]
                ) {
                    generateHaptic()
                    selectedTab = .games
                }
                
                ModernQuickActionButton(
                    icon: "chart.bar.fill",
                    title: "Progreso",
                    gradient: [Color(hexString: "4dabf7"), Color(hexString: "667eea")]
                ) {
                    generateHaptic()
                    selectedTab = .progress
                }
                
                ModernQuickActionButton(
                    icon: "magnifyingglass",
                    title: "Buscar",
                    gradient: [Color(hexString: "f093fb"), Color(hexString: "764ba2")]
                ) {
                    generateHaptic()
                    selectedTab = .search
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: "ff6b6b"))
                
                Text("Tus Favoritos")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(progressManager.progreso.elementosFavoritos.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hexString: "ff6b6b"), in: Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(progressManager.progreso.elementosFavoritos.prefix(8)), id: \.self) { elementoID in
                        if let elemento = dataManager.buscarElemento(porID: elementoID) {
                            NavigationLink(destination: ElementDetailView(elemento: elemento)) {
                                ModernElementMiniCard(elemento: elemento)
                            }
                        }
                    }
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
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
    
    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "☀️"
        case 12..<18:
            return "🌤️"
        default:
            return "🌙"
        }
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Modern Components

struct ModernElementOfTheDayCard: View {
    let elemento: Elemento
    
    @State private var scale: CGFloat = 0.95
    
    var body: some View {
        NavigationLink(destination: ElementDetailView(elemento: elemento)) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Elemento del Día")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Color(hexString: "ffd43b"))
                        
                        Text("Descubre algo nuevo")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                // Element display
                HStack(spacing: 20) {
                    // Symbol with gradient background
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
                            .frame(width: 80, height: 80)
                        
                        Text(elemento.simbolo)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(elemento.nombreLocalizado)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "atom")
                                .font(.system(size: 12, weight: .semibold))
                            Text("No. \(elemento.id)")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15), in: Capsule())
                        
                        Text(elemento.familia.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                    }
                    
                    Spacer()
                }
            }
            .padding(24)
            .background {
                ZStack {
                    // Colored background layer
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hexString: "667eea").opacity(0.15),
                                    Color(hexString: "764ba2").opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glass material on top
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThickMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
            .shadow(color: Color(hexString: "667eea").opacity(0.25), radius: 24, x: 0, y: 12)
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
            }
        }
        .accessibleButton(
            label: "Elemento del día: \(elemento.nombreLocalizado), símbolo \(elemento.simbolo)",
            hint: "Toca para ver detalles"
        )
    }
}

struct ModernQuickActionButton: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [gradient[0].opacity(0.2), gradient[1].opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [gradient[0], gradient[1]],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background {
                ZStack {
                    // Colored background layer
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [gradient[0].opacity(0.12), gradient[1].opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glass material on top
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThickMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: gradient[0].opacity(0.2), radius: 16, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .accessibleButton(label: title)
    }
}

struct ModernElementMiniCard: View {
    let elemento: Elemento
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.25),
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Text(elemento.simbolo)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
            }
            
            VStack(spacing: 2) {
                Text(elemento.nombreLocalizado)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("No. \(elemento.id)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background {
            ZStack {
                // Colored background layer
                RoundedRectangle(cornerRadius: 18)
                    .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.12))
                
                // Glass material on top
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    ColorPalette.colorParaFamilia(elemento.familia).opacity(0.4),
                    lineWidth: 1.5
                )
        }
        .shadow(color: ColorPalette.colorParaFamilia(elemento.familia).opacity(0.2), radius: 12, x: 0, y: 6)
        .accessibleButton(label: elemento.nombreLocalizado)
    }
}

// MARK: - Preview
#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
