//
//  GamesHubView.swift
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

// Custom ButtonStyle for press animations
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - GamesHubView
struct GamesHubView: View {
    @EnvironmentObject var dataManager: DataManager
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
                        // Header section
                        headerSection
                            .padding(.top, 8)
                        
                        // Stats cards
                        statsSection
                        
                        // Games grid
                        gamesSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Juegos")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: TipoJuego.self) { juego in
                gameDestination(for: juego)
            }
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
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
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
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Centro de Juegos")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Aprende jugando")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var statsSection: some View {
        HStack(spacing: 14) {
            StatBadge(
                icon: "trophy.fill",
                label: "Jugados",
                value: "\(totalGamesPlayed)",
                color: Color(hexString: "ffd43b")
            )
            
            StatBadge(
                icon: "star.fill",
                label: "Puntos",
                value: "\(totalPoints)",
                color: Color(hexString: "51cf66")
            )
            
            StatBadge(
                icon: "flame.fill",
                label: "Racha",
                value: "\(progressManager.progreso.rachaActual)d",
                color: Color(hexString: "ff6b6b")
            )
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var gamesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hexString: "667eea"))
                
                Text("Todos los Juegos")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(TipoJuego.allCases.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hexString: "667eea"), in: Capsule())
            }
            
            VStack(spacing: 12) {
                ForEach(TipoJuego.allCases, id: \.self) { juego in
                    NavigationLink(value: juego) {
                        GameRowView(tipoJuego: juego)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Computed Properties
    
    private var totalGamesPlayed: Int {
        progressManager.progreso.sesionesJuego.count
    }
    
    private var totalPoints: Int {
        progressManager.progreso.sesionesJuego.reduce(0) { $0 + $1.puntuacion }
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    private func gameDestination(for juego: TipoJuego) -> some View {
        switch juego {
        case .flashcards:
            FlashcardGameView()
        case .quiz:
            QuizGameView()
        case .parejas:
            PairsGameView()
        case .retoRelampago:
            LightningGameView()
        case .bingo:
            BingoGameView()
        case .adivinaPropiedad:
            GuessPropertyGameView()
        case .mapaPorFamilias:
            FamilyMapGameView()
        }
    }
}

// MARK: - StatBadge Component

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .monospacedDigit()
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.12), color.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: color.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Preview
#Preview("Juegos") {
    GamesHubView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
}
