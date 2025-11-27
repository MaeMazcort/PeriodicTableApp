//
//  BingoCardView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  5×5 Bingo card grid
//

import SwiftUI
import UIKit

private extension Color {
    static let bingoStart = Color(red: 102.0/255.0, green: 126.0/255.0, blue: 234.0/255.0)
    static let bingoEnd = Color(red: 118.0/255.0, green: 75.0/255.0, blue: 162.0/255.0)
}

struct BingoCardView: View {
    let card: BingoCard
    let onCellTap: (Int) -> Void
    
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        VStack(spacing: 8) {
            // "BINGO" header
            bingoHeader
            
            // 5×5 Grid
            VStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { col in
                            bingoCellView(card.cells[row][col])
                        }
                    }
                }
            }
            .padding(12)
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
            .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
            }
        }
    }
    
    // MARK: - BINGO Header
    private var bingoHeader: some View {
        HStack(spacing: 4) {
            ForEach(Array("BINGO"), id: \.self) { letter in
                Text(String(letter))
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.bingoStart, Color.bingoEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
    }
    
    // MARK: - Cell View
    private func bingoCellView(_ cell: BingoCell) -> some View {
        Button {
            generateHaptic(style: .light)
            onCellTap(cell.id)
        } label: {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        cell.isMarked
                        ? LinearGradient(
                            colors: [Color.bingoStart, Color.bingoEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                cell.isMarked
                                ? Color.bingoStart.opacity(0.6)
                                : Color.gray.opacity(0.2),
                                lineWidth: cell.isMarked ? 2 : 1
                            )
                    }
                    .shadow(
                        color: cell.isMarked
                        ? Color.bingoStart.opacity(0.4)
                        : .black.opacity(0.05),
                        radius: cell.isMarked ? 8 : 4,
                        x: 0,
                        y: cell.isMarked ? 4 : 2
                    )
                
                // Content
                VStack(spacing: 2) {
                    Text(cell.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(cell.isMarked ? .white : .primary)
                    
                    Text(cell.name)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(cell.isMarked ? .white.opacity(0.9) : .secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                
                // Checkmark for marked cells
                if cell.isMarked {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                        }
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .scaleEffect(cell.isMarked ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cell.isMarked)
    }
    
    private func generateHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Preview
struct BingoCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.bingoStart.opacity(0.12),
                    Color.bingoEnd.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                BingoCardView(
                    card: BingoCard(elementos: [
                        Elemento(id: 1, simbolo: "H", nombreES: "Hidrógeno", nombreEN: "Hydrogen", familia: FamiliaElemento(rawValue: "No Metales") ?? FamiliaElemento(rawValue: "No Metales")!, periodo: 1, grupo: 1, masaAtomica: 1.008, estado25C: EstadoMateria(rawValue: "Gas") ?? EstadoMateria(rawValue: "Gas")!, densidad: 0.00008988, puntoFusionC: -259.16, puntoEbullicionC: -252.87, configuracionElectronica: "1s¹", electronegatividad: 2.20, radioAtomico: 53, energiaIonizacion: 1312, usosES: [], usosEN: [], curiosidadesES: "", curiosidadesEN: "", seguridadES: nil, seguridadEN: nil),
                        // ... más elementos para llenar 25 celdas
                    ]),
                    onCellTap: { _ in }
                )
                .padding()
            }
        }
    }
}

