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

struct PeriodicTableView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var ttsManager: TTSManager
    @State private var selectedElement: Elemento?
    @State private var showElementDetail = false
    @State private var zoomLevel: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    // Zoom controls
                    zoomControls
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    
                    // Main scrollable content
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        if dataManager.isLoading {
                            loadingView
                        } else if let errorMessage = dataManager.errorMessage {
                            errorView(message: errorMessage)
                        } else {
                            periodicTableContent
                                .scaleEffect(zoomLevel)
                        }
                    }
                }
            }
            .navigationTitle("Tabla Periódica")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showElementDetail) {
            if let elemento = selectedElement {
                ElementDetailView(elemento: elemento)
                    .environmentObject(progressManager)
                    .environmentObject(ttsManager)
            }
        }
    }
    
    // MARK: - Zoom Controls
    
    private var zoomControls: some View {
        HStack(spacing: 12) {
            // Zoom out button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    zoomLevel = max(0.6, zoomLevel - 0.1)
                }
                HapticManager.impact(.light)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hexString: "667eea").opacity(0.3),
                                    Color(hexString: "667eea").opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hexString: "667eea"))
                }
            }
            
            // Reset button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    zoomLevel = 1.0
                }
                HapticManager.impact(.medium)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hexString: "51cf66").opacity(0.3),
                                    Color(hexString: "51cf66").opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hexString: "51cf66"))
                }
            }
            
            // Zoom in button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    zoomLevel = min(1.5, zoomLevel + 0.1)
                }
                HapticManager.impact(.light)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hexString: "667eea").opacity(0.3),
                                    Color(hexString: "667eea").opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hexString: "667eea"))
                }
            }
            
            Spacer()
            
            // Zoom indicator
            Text("\(Int(zoomLevel * 100))%")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(hexString: "667eea"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hexString: "667eea").opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.10),
                                Color(hexString: "764ba2").opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: Color(hexString: "667eea").opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hexString: "667eea").opacity(0.08),
                Color(hexString: "764ba2").opacity(0.06),
                Color(hexString: "f093fb").opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.3),
                                Color(hexString: "764ba2").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                SwiftUI.ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hexString: "667eea"))
            }
            
            Text("Cargando elementos...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hexString: "667eea"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "ff6b6b").opacity(0.3),
                                Color(hexString: "ffa94d").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(Color(hexString: "ff6b6b"))
            }
            
            VStack(spacing: 12) {
                Text("Error al cargar")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Periodic Table Content
    
    private var periodicTableContent: some View {
        VStack(spacing: 6) {
            // Main table (7 periods × 18 groups)
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<18, id: \.self) { col in
                        if let elemento = getElement(periodo: row + 1, grupo: col + 1) {
                            ModernElementCard(elemento: elemento) {
                                selectedElement = elemento
                                showElementDetail = true
                                HapticManager.impact(.medium)
                            }
                        } else {
                            Color.clear
                                .frame(width: 70, height: 70)
                        }
                    }
                }
            }
            
            Spacer().frame(height: 16)
            
            // Lanthanides row
            HStack(spacing: 6) {
                ForEach(getLanthanides()) { elemento in
                    ModernElementCard(elemento: elemento) {
                        selectedElement = elemento
                        showElementDetail = true
                        HapticManager.impact(.medium)
                    }
                }
            }
            
            // Actinides row
            HStack(spacing: 6) {
                ForEach(getActinides()) { elemento in
                    ModernElementCard(elemento: elemento) {
                        selectedElement = elemento
                        showElementDetail = true
                        HapticManager.impact(.medium)
                    }
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Helper Functions
    
    func getElement(periodo: Int, grupo: Int) -> Elemento? {
        return dataManager.elementos.first { elemento in
            elemento.periodo == periodo && elemento.grupo == grupo
        }
    }
    
    func getLanthanides() -> [Elemento] {
        return dataManager.elementos.filter { $0.familia == .lantanidos }
            .sorted { $0.id < $1.id }
    }
    
    func getActinides() -> [Elemento] {
        return dataManager.elementos.filter { $0.familia == .actinidos }
            .sorted { $0.id < $1.id }
    }
}

// MARK: - Modern Element Card

struct ModernElementCard: View {
    let elemento: Elemento
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                // Atomic number
                Text("\(elemento.id)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(elementColor.opacity(0.8))
                
                // Symbol
                Text(elemento.simbolo)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(elementColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                // Name
                Text(elemento.nombreLocalizado)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(elementColor.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            .frame(width: 70, height: 70)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    elementColor.opacity(0.20),
                                    elementColor.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThickMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: [
                                elementColor.opacity(0.5),
                                elementColor.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: elementColor.opacity(0.2), radius: 6, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
    }
    
    private var elementColor: Color {
        if elemento.familia == .metalesTransicion {
            return ColorPalette.colorParaFamilia(.metalesAlcalinoterreos)
        }
        return ColorPalette.colorParaFamilia(elemento.familia)
    }
}

#Preview {
    PeriodicTableView()
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
