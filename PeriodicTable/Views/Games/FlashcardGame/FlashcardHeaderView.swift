//
//  FlashcardHeaderView.swift
//  PeriodicTable
//
//  Enhanced progress header for flashcard game
//

import SwiftUI

struct FlashcardHeaderView: View {
    let currentIndex: Int
    let totalCards: Int
    let correctCount: Int
    let incorrectCount: Int
    
    var progress: Double {
        guard totalCards > 0 else { return 0 }
        let ratio = Double(currentIndex) / Double(totalCards)
        return min(max(ratio, 0), 1)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)
                    
                    // Progress fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(ptHex: "667eea"), Color(ptHex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * progress), height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
            
            // Stats row
            HStack(spacing: 20) {
                // Card counter
                HStack(spacing: 8) {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(ptHex: "667eea"), Color(ptHex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("\(currentIndex + 1)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    
                    Text("/")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(totalCards)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
                
                Spacer()
                
                // Score indicators
                HStack(spacing: 12) {
                    // Correct count
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(ptHex: "51cf66"))
                        
                        Text("\(correctCount)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(ptHex: "51cf66").opacity(0.12), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color(ptHex: "51cf66").opacity(0.3), lineWidth: 1)
                    }
                    
                    // Incorrect count
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(ptHex: "ff6b6b"))
                        
                        Text("\(incorrectCount)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(ptHex: "ff6b6b").opacity(0.12), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color(ptHex: "ff6b6b").opacity(0.3), lineWidth: 1)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Color Extension
extension Color {
    init(ptHex: String) {
        let hex = ptHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        FlashcardHeaderView(
            currentIndex: 0,
            totalCards: 10,
            correctCount: 0,
            incorrectCount: 0
        )
        
        FlashcardHeaderView(
            currentIndex: 5,
            totalCards: 10,
            correctCount: 4,
            incorrectCount: 1
        )
        
        FlashcardHeaderView(
            currentIndex: 9,
            totalCards: 10,
            correctCount: 8,
            incorrectCount: 1
        )
    }
    .padding()
    .background(
        LinearGradient(
            colors: [
                Color(ptHex: "667eea").opacity(0.12),
                Color(ptHex: "764ba2").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

