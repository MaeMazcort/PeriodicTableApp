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
    @State private var selectedElement: Elemento?
    @State private var showElementDetail = false
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                if dataManager.isLoading {
                    loadingView
                } else if let errorMessage = dataManager.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    periodicTableContent
                }
            }
        }
        .sheet(isPresented: $showElementDetail) {
            if let elemento = selectedElement {
                ElementDetailView(elemento: elemento)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
        }
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
        VStack(spacing: 8) {
            // Header
            tableHeader
                .padding(.bottom, 12)
            
            // Main table (periods 1-7)
            VStack(spacing: 6) {
                ForEach(0..<7) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<18) { col in
                            if let elemento = getElement(periodo: row + 1, grupo: col + 1) {
                                ModernElementCard(elemento: elemento) {
                                    selectedElement = elemento
                                    showElementDetail = true
                                    
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }
                            } else {
                                Color.clear
                                    .frame(width: 75, height: 75)
                            }
                        }
                    }
                }
            }
            
            Spacer().frame(height: 24)
            
            // Lanthanides & Actinides
            lanthanideActinideSection
        }
        .padding(20)
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Table Header
    
    private var tableHeader: some View {
        HStack(spacing: 12) {
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
                    .frame(width: 48, height: 48)
                
                Image(systemName: "atom")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(hexString: "667eea"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Tabla Periódica")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("\(dataManager.elementos.count) elementos")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
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
        .shadow(color: Color(hexString: "667eea").opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Lanthanides & Actinides Section
    
    private var lanthanideActinideSection: some View {
        VStack(spacing: 16) {
            // Section label
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hexString: "f093fb"))
                
                Text("Lantánidos y Actínidos")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                // Lanthanides
                HStack(spacing: 6) {
                    ForEach(getLanthanides()) { elemento in
                        ModernElementCard(elemento: elemento) {
                            selectedElement = elemento
                            showElementDetail = true
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    }
                }
                
                // Actinides
                HStack(spacing: 6) {
                    ForEach(getActinides()) { elemento in
                        ModernElementCard(elemento: elemento) {
                            selectedElement = elemento
                            showElementDetail = true
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    }
                }
            }
        }
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
            VStack(spacing: 4) {
                // Atomic number
                Text("\(elemento.id)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(elementColor.opacity(0.8))
                
                // Symbol
                Text(elemento.simbolo)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(elementColor)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                // Name
                Text(elemento.nombreLocalizado)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(elementColor.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: 75, height: 75)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
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
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThickMaterial)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
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
            .shadow(color: elementColor.opacity(0.25), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Element Color
    
    private var elementColor: Color {
        // Use transition metal color if available, otherwise use family color
        if elemento.familia == .metalesTransicion {
            // Check if we have the color in ColorPalette, otherwise use alkaline earth metals color
            return ColorPalette.colorParaFamilia(.metalesAlcalinoterreos)
        }
        return ColorPalette.colorParaFamilia(elemento.familia)
    }
}

#Preview {
    PeriodicTableView()
}
