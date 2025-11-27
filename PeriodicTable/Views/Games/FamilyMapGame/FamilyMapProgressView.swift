//
//  FamilyMapProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Progress header for family map game
//

import SwiftUI

struct FamilyMapProgressView: View {
    let currentElement: Int
    let totalElements: Int
    let correctCount: Int
    let incorrectCount: Int
    let elapsedTime: Int
    
    var progress: Double {
        guard totalElements > 0 else { return 0 }
        return Double(currentElement) / Double(totalElements)
    }
    
    static func hexColor(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var body: some View {
        VStack(spacing: 14) {
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
                                colors: [FamilyMapProgressView.hexColor("667eea"), FamilyMapProgressView.hexColor("764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
            
            // Stats row
            HStack(spacing: 16) {
                // Element counter
                HStack(spacing: 8) {
                    Image(systemName: "atom")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [FamilyMapProgressView.hexColor("667eea"), FamilyMapProgressView.hexColor("764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("\(currentElement)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    
                    Text("/")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(totalElements)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
                
                Spacer()
                
                // Score counters
                HStack(spacing: 12) {
                    // Correct count
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(FamilyMapProgressView.hexColor("51cf66"))
                        
                        Text("\(correctCount)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(FamilyMapProgressView.hexColor("51cf66").opacity(0.12), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(FamilyMapProgressView.hexColor("51cf66").opacity(0.3), lineWidth: 1)
                    }
                    
                    // Incorrect count
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(FamilyMapProgressView.hexColor("ff6b6b"))
                        
                        Text("\(incorrectCount)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(FamilyMapProgressView.hexColor("ff6b6b").opacity(0.12), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(FamilyMapProgressView.hexColor("ff6b6b").opacity(0.3), lineWidth: 1)
                    }
                }
            }
            
            // Timer
            HStack {
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(formattedTime)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .monospacedDigit()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
    
    private var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
struct FamilyMapProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    FamilyMapProgressView.hexColor("667eea").opacity(0.12),
                    FamilyMapProgressView.hexColor("764ba2").opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                FamilyMapProgressView(
                    currentElement: 1,
                    totalElements: 10,
                    correctCount: 0,
                    incorrectCount: 0,
                    elapsedTime: 0
                )
                
                FamilyMapProgressView(
                    currentElement: 5,
                    totalElements: 10,
                    correctCount: 4,
                    incorrectCount: 0,
                    elapsedTime: 65
                )
                
                FamilyMapProgressView(
                    currentElement: 10,
                    totalElements: 10,
                    correctCount: 7,
                    incorrectCount: 3,
                    elapsedTime: 195
                )
            }
            .padding()
        }
    }
}
