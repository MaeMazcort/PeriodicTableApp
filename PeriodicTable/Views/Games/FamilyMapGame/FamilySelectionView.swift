//
//  FamilySelectionView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//  Family selection grid with colored zones
//

import SwiftUI

struct FamilySelectionView: View {
    let onSelect: (ChemicalFamily) -> Void
    let disabled: Bool
    
    // Organize families in a visually appealing grid
    private let familyGroups: [[ChemicalFamily]] = [
        [.metalesAlcalinos, .metalesAlcalinoterreos],
        [.metalesTransicion, .lantanidos],
        [.actinidos, .otrosMetales],
        [.metaloides, .noMetales],
        [.halogenos, .gasesNobles]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(familyGroups.indices, id: \.self) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(familyGroups[rowIndex], id: \.self) { family in
                        familyButton(family)
                    }
                }
            }
        }
    }
    
    private func familyButton(_ family: ChemicalFamily) -> some View {
        Button {
            if !disabled {
                generateHaptic()
                onSelect(family)
            }
        } label: {
            VStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hexString: family.color).opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: family.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(hexString: family.color))
                }
                
                // Name
                Text(family.shortName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hexString: family.color).opacity(0.3), lineWidth: 2)
            }
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1.0)
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Compact Version for Small Screens
struct FamilySelectionCompactView: View {
    let onSelect: (ChemicalFamily) -> Void
    let disabled: Bool
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ChemicalFamily.allCases) { family in
                    familyButton(family)
                }
            }
        }
    }
    
    private func familyButton(_ family: ChemicalFamily) -> some View {
        Button {
            if !disabled {
                generateHaptic()
                onSelect(family)
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hexString: family.color).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: family.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hexString: family.color))
                }
                
                // Name
                Text(family.shortName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hexString: family.color).opacity(0.3), lineWidth: 1.5)
            }
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1.0)
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Preview
struct FamilySelectionView_Previews: PreviewProvider {
    static var previews: some View {
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
            
            VStack(spacing: 30) {
                FamilySelectionView(
                    onSelect: { _ in },
                    disabled: false
                )
                .padding()
                
                Divider()
                
                FamilySelectionCompactView(
                    onSelect: { _ in },
                    disabled: false
                )
                .frame(height: 300)
                .padding()
            }
        }
    }
}

