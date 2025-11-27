//
//  ElementDetailView.swift
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

// MARK: - ElementDetailView (vista completa del elemento)
struct ElementDetailView: View {
    let elemento: Elemento
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var ttsManager: TTSManager
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header con símbolo
                        headerSection
                            .padding(.top, 8)
                        
                        // Propiedades básicas
                        basicPropertiesSection
                        
                        // Propiedades físicas
                        if elemento.densidad != nil || elemento.puntoFusionC != nil {
                            physicalPropertiesSection
                        }
                        
                        // Propiedades químicas
                        if elemento.electronegatividad != nil || elemento.configuracionElectronica != nil {
                            chemicalPropertiesSection
                        }
                        
                        // Usos
                        if !elemento.usosLocalizados.isEmpty {
                            usesSection
                        }
                        
                        // Curiosidades
                        if let curiosidades = elemento.curiosidadesES {
                            funFactsSection(curiosidades)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        progressManager.toggleFavorito(elemento.id)
                        HapticManager.impact(.light)
                    } label: {
                        Image(systemName: progressManager.esFavorito(elemento.id) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    .accessibleButton(
                        label: progressManager.esFavorito(elemento.id) ? "Quitar de favoritos" : "Agregar a favoritos"
                    )
                }
                
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
                progressManager.registrarVistaElemento(elemento.id)
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.12),
                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.08),
                Color(hexString: "667eea").opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Secciones
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Símbolo grande con efecto glassmorphism
            ZStack {
                // Outer glow circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.3),
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.35),
                                ColorPalette.colorParaFamilia(elemento.familia).opacity(0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                VStack(spacing: 2) {
                    Text(elemento.simbolo)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                    
                    Text("\(elemento.id)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                        )
                }
            }
            .shadow(color: ColorPalette.colorParaFamilia(elemento.familia).opacity(0.3), radius: 30, x: 0, y: 15)
            
            // Nombre
            Text(elemento.nombreLocalizado)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            ColorPalette.colorParaFamilia(elemento.familia),
                            ColorPalette.colorParaFamilia(elemento.familia).opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Familia badge
            Text(elemento.familia.rawValue)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ColorPalette.colorParaFamilia(elemento.familia))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15))
                }
            
            // Botón de pronunciar moderno
            Button {
                if ttsManager.isPlaying {
                    ttsManager.detener()
                } else {
                    ttsManager.pronunciarElemento(elemento)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: ttsManager.isPlaying ? "stop.circle.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(ttsManager.isPlaying ? "Detener" : "Escuchar")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background {
                    ZStack {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ColorPalette.colorParaFamilia(elemento.familia),
                                        ColorPalette.colorParaFamilia(elemento.familia).opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
                .shadow(color: ColorPalette.colorParaFamilia(elemento.familia).opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .accessibleButton(
                label: ttsManager.isPlaying ? "Detener pronunciación" : "Escuchar pronunciación del elemento"
            )
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var basicPropertiesSection: some View {
        ModernPropertyCard(
            title: "Propiedades Básicas",
            icon: "info.circle.fill",
            color: Color(hexString: "667eea")
        ) {
            VStack(spacing: 16) {
                ModernPropertyRow(
                    icon: "number",
                    label: "Número Atómico",
                    value: "\(elemento.id)",
                    color: Color(hexString: "667eea")
                )
                
                if let masa = elemento.masaAtomica {
                    ModernPropertyRow(
                        icon: "scalemass",
                        label: "Masa Atómica",
                        value: String(format: "%.3f u", masa),
                        color: Color(hexString: "764ba2")
                    )
                }
                
                ModernPropertyRow(
                    icon: "chart.bar.fill",
                    label: "Periodo",
                    value: "\(elemento.periodo)",
                    color: Color(hexString: "51cf66")
                )
                
                if let grupo = elemento.grupo {
                    ModernPropertyRow(
                        icon: "square.grid.3x3",
                        label: "Grupo",
                        value: "\(grupo)",
                        color: Color(hexString: "38d9a9")
                    )
                }
                
                ModernPropertyRow(
                    icon: elemento.estado25C.icono,
                    label: "Estado (25°C)",
                    value: elemento.estado25C.rawValue,
                    color: ColorPalette.colorParaFamilia(elemento.familia)
                )
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var physicalPropertiesSection: some View {
        ModernPropertyCard(
            title: "Propiedades Físicas",
            icon: "flame.fill",
            color: Color(hexString: "ff6b6b")
        ) {
            VStack(spacing: 16) {
                if let densidad = elemento.densidad {
                    ModernPropertyRow(
                        icon: "cube",
                        label: "Densidad",
                        value: String(format: "%.3f g/cm³", densidad),
                        color: Color(hexString: "ff6b6b")
                    )
                }
                
                if let fusion = elemento.puntoFusionC {
                    ModernPropertyRow(
                        icon: "thermometer.low",
                        label: "Punto de Fusión",
                        value: String(format: "%.1f °C", fusion),
                        color: Color(hexString: "4dabf7")
                    )
                }
                
                if let ebullicion = elemento.puntoEbullicionC {
                    ModernPropertyRow(
                        icon: "thermometer.high",
                        label: "Punto de Ebullición",
                        value: String(format: "%.1f °C", ebullicion),
                        color: Color(hexString: "ffa94d")
                    )
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var chemicalPropertiesSection: some View {
        ModernPropertyCard(
            title: "Propiedades Químicas",
            icon: "atom",
            color: Color(hexString: "f093fb")
        ) {
            VStack(spacing: 16) {
                if let config = elemento.configuracionElectronica {
                    ModernPropertyRow(
                        icon: "atom",
                        label: "Configuración Electrónica",
                        value: config,
                        color: Color(hexString: "f093fb"),
                        isMultiline: true
                    )
                }
                
                if let electroneg = elemento.electronegatividad {
                    ModernPropertyRow(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Electronegatividad",
                        value: String(format: "%.2f (Pauling)", electroneg),
                        color: Color(hexString: "764ba2")
                    )
                }
                
                if let radioAtomico = elemento.radioAtomico {
                    ModernPropertyRow(
                        icon: "circle.dotted",
                        label: "Radio Atómico",
                        value: "\(radioAtomico) pm",
                        color: Color(hexString: "667eea")
                    )
                }
                
                if let energiaIonizacion = elemento.energiaIonizacion {
                    ModernPropertyRow(
                        icon: "bolt.fill",
                        label: "Energía de Ionización",
                        value: String(format: "%.1f kJ/mol", energiaIonizacion),
                        color: Color(hexString: "ffd43b")
                    )
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var usesSection: some View {
        ModernPropertyCard(
            title: "Usos Comunes",
            icon: "wrench.and.screwdriver.fill",
            color: Color(hexString: "51cf66")
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(elemento.usosLocalizados, id: \.self) { uso in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hexString: "51cf66").opacity(0.15))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hexString: "51cf66"))
                        }
                        
                        Text(uso)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private func funFactsSection(_ curiosidades: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hexString: "ffd43b").opacity(0.3),
                                    Color(hexString: "ffd43b").opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(hexString: "ffd43b"))
                }
                
                Text("¿Sabías que...?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .accessibleHeader("Curiosidad")
            
            Text(curiosidades)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
                .lineSpacing(6)
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "ffd43b").opacity(0.12),
                                Color(hexString: "ffa94d").opacity(0.08)
                            ],
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
        .shadow(color: Color(hexString: "ffd43b").opacity(0.2), radius: 16, x: 0, y: 8)
        .scaleEffect(scale)
        .opacity(opacity)
    }
}

// MARK: - Modern Components

struct ModernPropertyCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .accessibleHeader(title)
            
            // Content
            content
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.10), color.opacity(0.05)],
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
        .shadow(color: color.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

struct ModernPropertyRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    var isMultiline: Bool = false
    
    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 14) {
            // Icon with circle background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            // Label and value
            if isMultiline {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
        }
        .accessibleGroup(label: "\(label): \(value)")
    }
}

// MARK: - Previews
#Preview("Detalle de Elemento") {
    ElementDetailView(elemento: .ejemploHidrogeno)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
