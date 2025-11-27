//
//  OnboardingView.swift
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

struct OnboardingView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @State private var currentPage = 0
    @State private var selectedLanguage: Idioma = .espanol
    @State private var selectedTheme: TemaVisual = .sistema
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Animated background gradient
            AnimatedGradientBackground(currentPage: currentPage)
            
            VStack(spacing: 0) {
                // Page indicator
                pageIndicator
                    .padding(.top, 60)
                
                // Content pages
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    languagePage.tag(1)
                    accessibilityPage.tag(2)
                    readyPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { oldValue, newValue in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                        scale = 0.95
                        opacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                            scale = 1.0
                            opacity = 1.0
                        }
                    }
                }
                
                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    // MARK: - Pages
    
    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon with glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.4),
                                Color(hexString: "764ba2").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "667eea").opacity(0.6),
                                Color(hexString: "764ba2").opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Image(systemName: "atom")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .shadow(color: Color(hexString: "667eea").opacity(0.5), radius: 40, x: 0, y: 20)
            .accessibilityHidden(true)
            
            VStack(spacing: 16) {
                Text("Bienvenido")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .accessibleTitle()
                
                Text("Explora la tabla periódica de forma interactiva y accesible")
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
            }
            
            // Features preview
            HStack(spacing: 20) {
                FeatureBadge(icon: "gamecontroller.fill", label: "Juegos", color: Color(hexString: "51cf66"))
                FeatureBadge(icon: "book.fill", label: "Aprende", color: Color(hexString: "667eea"))
                FeatureBadge(icon: "star.fill", label: "Progreso", color: Color(hexString: "ffd43b"))
            }
            
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var languagePage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "4dabf7").opacity(0.3),
                                Color(hexString: "339af0").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "globe")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(Color(hexString: "4dabf7"))
            }
            .shadow(color: Color(hexString: "4dabf7").opacity(0.3), radius: 30, x: 0, y: 15)
            .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text("Elige tu idioma")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                    .accessibleTitle()
                
                Text("Puedes cambiarlo después")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 14) {
                ForEach(Idioma.allCases, id: \.self) { idioma in
                    ModernLanguageButton(
                        idioma: idioma,
                        isSelected: selectedLanguage == idioma
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLanguage = idioma
                            progressManager.settings.idioma = idioma
                        }
                        
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var accessibilityPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "51cf66").opacity(0.3),
                                Color(hexString: "38d9a9").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "accessibility")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(Color(hexString: "51cf66"))
            }
            .shadow(color: Color(hexString: "51cf66").opacity(0.3), radius: 30, x: 0, y: 15)
            .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text("Accesibilidad")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                    .accessibleTitle()
                
                Text("Diseñado para todos")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                ModernAccessibilityFeature(
                    icon: "speaker.wave.2.fill",
                    title: "VoiceOver",
                    description: "Compatible con lectores de pantalla",
                    color: Color(hexString: "667eea")
                )
                
                ModernAccessibilityFeature(
                    icon: "textformat.size",
                    title: "Texto Dinámico",
                    description: "Ajusta el tamaño del texto",
                    color: Color(hexString: "f093fb")
                )
                
                ModernAccessibilityFeature(
                    icon: "eye.fill",
                    title: "Alto Contraste",
                    description: "Colores accesibles para todos",
                    color: Color(hexString: "ffd43b")
                )
                
                ModernAccessibilityFeature(
                    icon: "bolt.fill",
                    title: "Offline",
                    description: "Funciona sin conexión a internet",
                    color: Color(hexString: "51cf66")
                )
            }
            .padding(.horizontal, 28)
            
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    private var readyPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success icon with celebration
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "51cf66").opacity(0.4),
                                Color(hexString: "38d9a9").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hexString: "51cf66").opacity(0.6),
                                Color(hexString: "38d9a9").opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .shadow(color: Color(hexString: "51cf66").opacity(0.5), radius: 40, x: 0, y: 20)
            .accessibilityHidden(true)
            
            VStack(spacing: 16) {
                Text("¡Todo listo!")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hexString: "51cf66"), Color(hexString: "38d9a9")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .accessibleTitle()
                
                Text("Comienza tu viaje por la tabla periódica")
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
            }
            
            // What you'll discover
            VStack(spacing: 12) {
                ReadyFeature(icon: "atom", text: "118 elementos químicos")
                ReadyFeature(icon: "gamecontroller.fill", text: "7 juegos educativos")
                ReadyFeature(icon: "chart.line.uptrend.xyaxis", text: "Seguimiento de progreso")
            }
            
            Spacer()
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }
    
    // MARK: - Components
    
    private var pageIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<4) { index in
                if currentPage == index {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hexString: "667eea"), Color(hexString: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 32, height: 8)
                        .shadow(color: Color(hexString: "667eea").opacity(0.4), radius: 8, x: 0, y: 4)
                } else {
                    Circle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Página \(currentPage + 1) de 4")
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if currentPage > 0 {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        currentPage -= 1
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Anterior")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background {
                        ZStack {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                            
                            Capsule()
                                .fill(.ultraThickMaterial)
                        }
                    }
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
                .accessibleButton(label: "Anterior")
            }
            
            Spacer()
            
            // Next/Start button
            Button {
                if currentPage < 3 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
                
                let generator = UIImpactFeedbackGenerator(style: currentPage == 3 ? .medium : .light)
                generator.impactOccurred()
            } label: {
                HStack(spacing: 8) {
                    Text(currentPage < 3 ? "Siguiente" : "Comenzar")
                        .font(.system(size: 16, weight: .bold))
                    
                    Image(systemName: currentPage < 3 ? "chevron.right" : "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    currentPage == 3 ? Color(hexString: "51cf66") : Color(hexString: "667eea"),
                                    currentPage == 3 ? Color(hexString: "38d9a9") : Color(hexString: "764ba2")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: (currentPage == 3 ? Color(hexString: "51cf66") : Color(hexString: "667eea")).opacity(0.4),
                            radius: 16,
                            x: 0,
                            y: 8
                        )
                }
            }
            .accessibleButton(label: currentPage < 3 ? "Siguiente" : "Comenzar a usar la aplicación")
        }
    }
    
    // MARK: - Functions
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            progressManager.settings.completoOnboarding = true
            progressManager.guardarSettings()
        }
    }
}

// MARK: - Animated Background

struct AnimatedGradientBackground: View {
    let currentPage: Int
    
    var body: some View {
        LinearGradient(
            colors: backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: currentPage)
    }
    
    private var backgroundColors: [Color] {
        switch currentPage {
        case 0:
            return [
                Color(hexString: "667eea").opacity(0.20),
                Color(hexString: "764ba2").opacity(0.15),
                Color(hexString: "f093fb").opacity(0.10)
            ]
        case 1:
            return [
                Color(hexString: "4dabf7").opacity(0.20),
                Color(hexString: "339af0").opacity(0.15),
                Color(hexString: "667eea").opacity(0.10)
            ]
        case 2:
            return [
                Color(hexString: "51cf66").opacity(0.20),
                Color(hexString: "38d9a9").opacity(0.15),
                Color(hexString: "4dabf7").opacity(0.10)
            ]
        case 3:
            return [
                Color(hexString: "51cf66").opacity(0.20),
                Color(hexString: "38d9a9").opacity(0.15),
                Color(hexString: "ffd43b").opacity(0.10)
            ]
        default:
            return [
                Color(hexString: "667eea").opacity(0.20),
                Color(hexString: "764ba2").opacity(0.15),
                Color(hexString: "f093fb").opacity(0.10)
            ]
        }
    }
}

// MARK: - Modern Components

struct FeatureBadge: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }
}

struct ModernLanguageButton: View {
    let idioma: Idioma
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 16) {
                // Flag or icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [Color(hexString: "667eea").opacity(0.3), Color(hexString: "764ba2").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(idioma == .espanol ? "🇲🇽" : "🇺🇸")
                        .font(.system(size: 24))
                }
                
                // Language name
                Text(idioma.nombre)
                    .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color(hexString: "51cf66"))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background {
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hexString: "667eea").opacity(0.15), Color(hexString: "764ba2").opacity(0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThickMaterial)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.05))
                        
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThickMaterial)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ?
                        LinearGradient(
                            colors: [Color(hexString: "667eea").opacity(0.5), Color(hexString: "764ba2").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(
                color: isSelected ? Color(hexString: "667eea").opacity(0.2) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibleButton(
            label: idioma.nombre,
            hint: isSelected ? "Seleccionado" : "Toca para seleccionar"
        )
    }
}

struct ModernAccessibilityFeature: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.08))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThickMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
        .accessibleGroup(label: "\(title): \(description)")
    }
}

struct ReadyFeature: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hexString: "51cf66"))
            
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(ProgressManager.shared)
}
