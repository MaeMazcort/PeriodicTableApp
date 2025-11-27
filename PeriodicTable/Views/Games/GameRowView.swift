//
//  GameRowView.swift
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

struct GameRowView: View {
    let tipoJuego: TipoJuego
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                gameColor.opacity(0.3),
                                gameColor.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: tipoJuego.icono)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(gameColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(tipoJuego.nombre)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if tipoJuego == .flashcards {
                        Text("NUEVO")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hexString: "ff6b6b"), in: Capsule())
                    }
                }
                
                Text(tipoJuego.descripcion)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Duration badge
            VStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(gameColor)
                
                Text("\(tipoJuego.duracionEstimadaMinutos)'")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(gameColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background {
            ZStack {
                // Colored background
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [gameColor.opacity(0.12), gameColor.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass material
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
        .shadow(color: gameColor.opacity(0.2), radius: 12, x: 0, y: 6)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
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

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.12),
                Color(hexString: "764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 16) {
            GameRowView(tipoJuego: .flashcards)
            GameRowView(tipoJuego: .quiz)
            GameRowView(tipoJuego: .bingo)
        }
        .padding()
    }
}
