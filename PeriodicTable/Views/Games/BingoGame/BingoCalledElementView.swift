//
//  BingoCalledElementView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Display current called element prominently
//

import SwiftUI

struct BingoCalledElementView: View {
    let element: Elemento?
    let totalCalled: Int
    
    @State private var scale: CGFloat = 0.8
    @State private var rotation: Double = -5
    
    var body: some View {
        VStack(spacing: 16) {
            // "LLAMANDO" label
            Text("LLAMANDO")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(2)
            
            if let element = element {
                // Element card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 24, x: 0, y: 12)
                    
                    VStack(spacing: 12) {
                        // Symbol - Extra large
                        Text(element.simbolo)
                            .font(.system(size: 64, weight: .bold))
                            .foregroundStyle(.white)
                        
                        // Name
                        Text(element.nombreES)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                        
                        // Atomic number badge
                        HStack(spacing: 6) {
                            Image(systemName: "atom")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("No. \(element.id)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.2), in: Capsule())
                    }
                    .padding(24)
                }
                .frame(height: 220)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        scale = 1.0
                        rotation = 0
                    }
                }
                .onChange(of: element.id) { _, _ in
                    // Animate on element change
                    scale = 0.8
                    rotation = -5
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        scale = 1.0
                        rotation = 0
                    }
                }
            } else {
                // Empty state
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        }
                    
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("Esperando...")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                }
                .frame(height: 220)
            }
            
            // Counter badge
            HStack(spacing: 8) {
                Image(systemName: "number")
                    .font(.system(size: 14, weight: .semibold))
                
                Text("\(totalCalled) elementos cantados")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Called Elements History
struct BingoCalledHistoryView: View {
    let elements: [Elemento]
    let maxDisplay: Int = 10
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "667eea"))
                
                Text("Últimos Cantados")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(elements.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "667eea"), in: Capsule())
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(elements.suffix(maxDisplay).reversed(), id: \.id) { element in
                        historyChip(element)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private func historyChip(_ element: Elemento) -> some View {
        VStack(spacing: 4) {
            Text(element.simbolo)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(element.nombreES)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 60, height: 60)
        .background(Color(hex: "667eea").opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "667eea").opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Preview
struct BingoCalledElementView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.12),
                    Color(hex: "764ba2").opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                BingoCalledElementView(
                    element: nil,
                    totalCalled: 5
                )
                
                BingoCalledHistoryView(
                    elements: []
                )
            }
            .padding()
        }
    }
}
