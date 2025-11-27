//
//  StatRow.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .accessibleGroup(label: "\(title): \(value)")
    }
}

#Preview {
    List {
        StatRow(icon: "flame.fill", title: "Racha Actual", value: "5 días", color: .orange)
        StatRow(icon: "star.fill", title: "Favoritos", value: "12", color: .yellow)
    }
}
