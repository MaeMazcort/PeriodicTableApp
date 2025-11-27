//
//  ProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Modern glassmorphism design with data visualization
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

struct ProgressView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero stats
                        heroStatsSection
                            .padding(.top, 16)
                        
                        // Stats grid
                        statsGridSection
                        
                        // Elements progress
                        elementsSection
                        
                        // Gaming stats
                        gamingSection
                        
                        // Achievements preview
                        achievementsSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Mi Progreso")
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
                Color(hexString: "667eea").opacity(0.15),
                Color(hexString: "764ba2").opacity(0.12),
                Color(hexString: "f093fb").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Hero Stats Section
    
    private var heroStatsSection: some View {
        HStack(spacing: 14) {
            // Streak card
            HeroStatCard(
                icon: "flame.fill",
                title: "Racha",
                value: "\(progressManager.progreso.rachaActual)",
                subtitle: "días seguidos",
                secondaryInfo: "Récord: \(progressManager.progreso.mejorRacha)",
                color: Color(hexString: "ff6b6b"),
                gradientColors: [Color(hexString: "ff6b6b"), Color(hexString: "ffa94d")]
            )
            
            // Precision card
            HeroStatCard(
                icon: "target",
                title: "Precisión",
                value: String(format: "%.0f", progressManager.progreso.porcentajePrecision),
                subtitle: "%",
                secondaryInfo: "de aciertos",
                color: Color(hexString: "51cf66"),
                gradientColors: [Color(hexString: "51cf66"), Color(hexString: "38d9a9")]
            )
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Stats Grid Section
    
    private var statsGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "chart.bar.fill", title: "Estadísticas", color: Color(hexString: "667eea"))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                CompactStatCard(
                    icon: "clock.fill",
                    title: "Tiempo",
                    value: "\(progressManager.progreso.tiempoTotalEstudioMinutos)",
                    unit: "min",
                    color: Color(hexString: "4dabf7")
                )
                
                CompactStatCard(
                    icon: "trophy.fill",
                    title: "Mejor Racha",
                    value: "\(progressManager.progreso.mejorRacha)",
                    unit: "días",
                    color: Color(hexString: "ffd43b")
                )
                
                CompactStatCard(
                    icon: "gamecontroller.fill",
                    title: "Sesiones",
                    value: "\(progressManager.progreso.sesionesJuego.count)",
                    unit: "juegos",
                    color: Color(hexString: "f093fb")
                )
                
                CompactStatCard(
                    icon: "star.fill",
                    title: "Puntos",
                    value: "\(totalPoints)",
                    unit: "pts",
                    color: Color(hexString: "ffd43b")
                )
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Elements Section
    
    private var elementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "atom", title: "Elementos", color: Color(hexString: "667eea"))
            
            VStack(spacing: 12) {
                // Favorites
                ElementProgressRow(
                    icon: "heart.fill",
                    title: "Favoritos",
                    value: progressManager.progreso.elementosFavoritos.count,
                    total: 118,
                    color: Color(hexString: "ff6b6b")
                )
                
                // Mastered
                ElementProgressRow(
                    icon: "checkmark.circle.fill",
                    title: "Dominados",
                    value: elementosDominados,
                    total: 118,
                    color: Color(hexString: "51cf66")
                )
                
                // Studied
                ElementProgressRow(
                    icon: "book.fill",
                    title: "Estudiados",
                    value: progressManager.progreso.elementosEstudiados.count,
                    total: 118,
                    color: Color(hexString: "4dabf7")
                )
            }
            .padding(20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color(hexString: "667eea").opacity(0.10), Color(hexString: "764ba2").opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
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
            .shadow(color: Color(hexString: "667eea").opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Gaming Section
    
    private var gamingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "gamecontroller.fill", title: "Juegos", color: Color(hexString: "f093fb"))
            
            VStack(spacing: 12) {
                GamingStatRow(
                    icon: "gamecontroller.fill",
                    title: "Sesiones totales",
                    value: "\(progressManager.progreso.sesionesJuego.count)",
                    color: Color(hexString: "f093fb")
                )
                
                GamingStatRow(
                    icon: "star.fill",
                    title: "Puntos acumulados",
                    value: "\(totalPoints)",
                    color: Color(hexString: "ffd43b")
                )
                
                if let bestScore = bestGameScore {
                    GamingStatRow(
                        icon: "trophy.fill",
                        title: "Mejor puntuación",
                        value: "\(bestScore)",
                        color: Color(hexString: "ffa94d")
                    )
                }
                
                if progressManager.progreso.sesionesJuego.count > 0 {
                    GamingStatRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Promedio por sesión",
                        value: "\(averageScore)",
                        color: Color(hexString: "51cf66")
                    )
                }
            }
            .padding(20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color(hexString: "f093fb").opacity(0.10), Color(hexString: "764ba2").opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
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
            .shadow(color: Color(hexString: "f093fb").opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(icon: "trophy.fill", title: "Logros", color: Color(hexString: "ffd43b"))
                
                Spacer()
                
                Text("\(unlockedAchievements)/\(totalAchievements)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hexString: "ffd43b"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hexString: "ffd43b").opacity(0.15), in: Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AchievementBadge(
                        icon: "flame.fill",
                        title: "Racha 7",
                        isUnlocked: progressManager.progreso.mejorRacha >= 7,
                        color: Color(hexString: "ff6b6b")
                    )
                    
                    AchievementBadge(
                        icon: "star.fill",
                        title: "10 Favoritos",
                        isUnlocked: progressManager.progreso.elementosFavoritos.count >= 10,
                        color: Color(hexString: "ffd43b")
                    )
                    
                    AchievementBadge(
                        icon: "checkmark.circle.fill",
                        title: "25 Dominados",
                        isUnlocked: elementosDominados >= 25,
                        color: Color(hexString: "51cf66")
                    )
                    
                    AchievementBadge(
                        icon: "gamecontroller.fill",
                        title: "50 Partidas",
                        isUnlocked: progressManager.progreso.sesionesJuego.count >= 50,
                        color: Color(hexString: "f093fb")
                    )
                    
                    AchievementBadge(
                        icon: "target",
                        title: "95% Precisión",
                        isUnlocked: progressManager.progreso.porcentajePrecision >= 95.0,
                        color: Color(hexString: "4dabf7")
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Computed Properties
    
    private var elementosDominados: Int {
        progressManager.progreso.elementosEstudiados.values.filter { $0.nivelDominio == .dominado }.count
    }
    
    private var totalPoints: Int {
        progressManager.progreso.sesionesJuego.reduce(0) { $0 + $1.puntuacion }
    }
    
    private var bestGameScore: Int? {
        progressManager.progreso.sesionesJuego.map { $0.puntuacion }.max()
    }
    
    private var averageScore: Int {
        guard !progressManager.progreso.sesionesJuego.isEmpty else { return 0 }
        return totalPoints / progressManager.progreso.sesionesJuego.count
    }
    
    private var unlockedAchievements: Int {
        var count = 0
        if progressManager.progreso.mejorRacha >= 7 { count += 1 }
        if progressManager.progreso.elementosFavoritos.count >= 10 { count += 1 }
        if elementosDominados >= 25 { count += 1 }
        if progressManager.progreso.sesionesJuego.count >= 50 { count += 1 }
        if progressManager.progreso.porcentajePrecision >= 95.0 { count += 1 }
        return count
    }
    
    private var totalAchievements: Int {
        return 5
    }
}

// MARK: - Components

struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
        }
    }
}

struct HeroStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let secondaryInfo: String
    let color: Color
    let gradientColors: [Color]
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(color)
            }
            
            // Title
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            // Value
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .monospacedDigit()
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // Secondary info
            Text(secondaryInfo)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.12), color.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
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
        .shadow(color: color.opacity(0.25), radius: 20, x: 0, y: 10)
    }
}

struct CompactStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(color)
                    .monospacedDigit()
                
                Text(unit)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.08))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
}

struct ElementProgressRow: View {
    let icon: String
    let title: String
    let value: Int
    let total: Int
    let color: Color
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(value)/\(total)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(color.opacity(0.15))
                        .frame(height: 8)
                    
                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct GamingStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked ?
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(isUnlocked ? color : Color.gray.opacity(0.5))
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.gray.opacity(0.8), in: Circle())
                        .offset(x: 24, y: 24)
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isUnlocked ?
                        color.opacity(0.08) :
                        Color.gray.opacity(0.05)
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isUnlocked ?
                    color.opacity(0.3) :
                    Color.white.opacity(0.2),
                    lineWidth: 1
                )
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview("Progreso") {
    ProgressView()
        .environmentObject(ProgressManager.shared)
}
