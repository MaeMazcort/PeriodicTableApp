//
//  GameViewPlaceholder.swift
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

struct GameViewPlaceholder: View {
    let tipoJuego: TipoJuego
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var rotation: Double = -5
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)
                        
                        // Main icon with glow
                        iconSection
                        
                        // Game info
                        infoSection
                        
                        // Coming soon badge
                        comingSoonBadge
                        
                        // Features preview
                        featuresSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle(tipoJuego.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                    rotation = 0
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                gameColor.opacity(0.20),
                gameColor.opacity(0.15),
                gameColor.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Sections
    
    private var iconSection: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            gameColor.opacity(0.4),
                            gameColor.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 30)
            
            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            gameColor.opacity(0.5),
                            gameColor.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
            
            // Icon
            Image(systemName: tipoJuego.icono)
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(gameColor)
        }
        .shadow(color: gameColor.opacity(0.4), radius: 40, x: 0, y: 20)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
    }
    
    private var infoSection: some View {
        VStack(spacing: 16) {
            Text(tipoJuego.nombre)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [gameColor, gameColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
            
            Text(tipoJuego.descripcion)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 20)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var comingSoonBadge: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("En Desarrollo")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hexString: "ffa94d"), Color(hexString: "ff6b6b")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .shadow(color: Color(hexString: "ffa94d").opacity(0.4), radius: 20, x: 0, y: 10)
            
            Text("¡Próximamente disponible!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(gameColor)
                
                Text("Características Próximas")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "brain.head.profile",
                    title: "Aprendizaje Interactivo",
                    description: "Aprende mientras te diviertes",
                    color: Color(hexString: "667eea")
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Seguimiento de Progreso",
                    description: "Observa tu mejora continua",
                    color: Color(hexString: "51cf66")
                )
                
                FeatureRow(
                    icon: "trophy.fill",
                    title: "Logros y Recompensas",
                    description: "Desbloquea insignias especiales",
                    color: Color(hexString: "ffd43b")
                )
                
                FeatureRow(
                    icon: "clock.fill",
                    title: "Duración: \(tipoJuego.duracionEstimadaMinutos) minutos",
                    description: "Sesiones rápidas y efectivas",
                    color: gameColor
                )
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [gameColor.opacity(0.12), gameColor.opacity(0.06)],
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
        .shadow(color: gameColor.opacity(0.2), radius: 20, x: 0, y: 10)
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Computed Properties
    
    private var gameColor: Color {
        switch tipoJuego {
        case .flashcards:
            return Color(hexString: "667eea")
        case .quiz:
            return Color(hexString: "51cf66")
        case .parejas:
            return Color(hexString: "f093fb")
        case .retoRelampago:
            return Color(hexString: "ffa94d")
        case .bingo:
            return Color(hexString: "4dabf7")
        case .adivinaPropiedad:
            return Color(hexString: "ff6b6b")
        case .mapaPorFamilias:
            return Color(hexString: "f7d64a")
        }
    }
}

// MARK: - FeatureRow Component

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    GameViewPlaceholder(tipoJuego: .quiz)
}
