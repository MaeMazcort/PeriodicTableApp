//
//  PairsProgressView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Progress header for pairs matching game
//

import SwiftUI

struct PairsProgressView: View {
    let matchedPairs: Int
    let totalPairs: Int
    let moves: Int
    let elapsedTime: Int
    
    var progress: Double {
        guard totalPairs > 0 else { return 0 }
        return Double(matchedPairs) / Double(totalPairs)
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
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
            
            // Stats row
            HStack(spacing: 16) {
                // Matches counter
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hexString: "51cf66"))
                    
                    Text("\(matchedPairs)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    
                    Text("/")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text("\(totalPairs)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hexString: "51cf66").opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color(hexString: "51cf66").opacity(0.3), lineWidth: 1)
                }
                
                Spacer()
                
                // Moves counter
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hexString: "667eea"))
                    
                    Text("\(moves)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hexString: "667eea").opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color(hexString: "667eea").opacity(0.3), lineWidth: 1)
                }
                
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(formattedTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .monospacedDigit()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
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
        
        VStack(spacing: 20) {
            PairsProgressView(
                matchedPairs: 0,
                totalPairs: 10,
                moves: 0,
                elapsedTime: 0
            )
            
            PairsProgressView(
                matchedPairs: 5,
                totalPairs: 10,
                moves: 12,
                elapsedTime: 45
            )
            
            PairsProgressView(
                matchedPairs: 10,
                totalPairs: 10,
                moves: 18,
                elapsedTime: 125
            )
        }
        .padding()
    }
}
