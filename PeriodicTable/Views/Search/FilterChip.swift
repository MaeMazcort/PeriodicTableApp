//
//  FilterChip.swift
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

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .semibold))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [filterColor, filterColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: filterColor.opacity(0.4), radius: 12, x: 0, y: 6)
                } else {
                    ZStack {
                        Capsule()
                            .fill(Color.gray.opacity(0.08))
                        
                        Capsule()
                            .fill(.ultraThickMaterial)
                    }
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibleButton(
            label: title,
            hint: isSelected ? "Seleccionado" : "Toca para filtrar"
        )
    }
    
    // MARK: - Computed Properties
    
    private var filterColor: Color {
        switch title {
        case "Todos":
            return Color(hexString: "667eea")
        case "Metales":
            return Color(hexString: "51cf66")
        case "No Metales":
            return Color(hexString: "ff6b6b")
        case "Gases":
            return Color(hexString: "4dabf7")
        case "Líquidos":
            return Color(hexString: "f093fb")
        case "Sólidos":
            return Color(hexString: "ffa94d")
        default:
            return Color(hexString: "667eea")
        }
    }
}

#Preview("Selected") {
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
        
        VStack(spacing: 12) {
            FilterChip(title: "Todos", isSelected: true, action: {})
            FilterChip(title: "Metales", isSelected: false, action: {})
            FilterChip(title: "Gases", isSelected: false, action: {})
        }
        .padding()
    }
}

#Preview("Not Selected") {
    FilterChip(title: "Gases", isSelected: false, action: {})
        .padding()
}
