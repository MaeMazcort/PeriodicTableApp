//
//  OnboardingView.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @State private var currentPage = 0
    @State private var selectedLanguage: Idioma = .espanol
    @State private var selectedTheme: TemaVisual = .sistema
    
    var body: some View {
        ZStack {
            ColorPalette.Sistema.fondo.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Indicador de página
                pageIndicator
                    .padding(.top, 40)
                
                // Contenido de la página
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    languagePage.tag(1)
                    accessibilityPage.tag(2)
                    readyPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Botones de navegación
                navigationButtons
                    .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Páginas
    
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "atom")
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            
            Text("Bienvenido")
                .font(.largeTitle)
                .fontWeight(.bold)
                .accessibleTitle()
            
            Text("Explora la tabla periódica de forma interactiva y accesible")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var languagePage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            
            Text("Elige tu idioma")
                .font(.title)
                .fontWeight(.bold)
                .accessibleTitle()
            
            VStack(spacing: 16) {
                ForEach(Idioma.allCases, id: \.self) { idioma in
                    LanguageButton(
                        idioma: idioma,
                        isSelected: selectedLanguage == idioma
                    ) {
                        selectedLanguage = idioma
                        progressManager.settings.idioma = idioma
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var accessibilityPage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "accessibility")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            
            Text("Accesibilidad")
                .font(.title)
                .fontWeight(.bold)
                .accessibleTitle()
            
            VStack(alignment: .leading, spacing: 20) {
                AccessibilityFeature(
                    icon: "speaker.wave.2.fill",
                    title: "VoiceOver",
                    description: "Compatible con lectores de pantalla"
                )
                
                AccessibilityFeature(
                    icon: "textformat.size",
                    title: "Texto Dinámico",
                    description: "Ajusta el tamaño del texto"
                )
                
                AccessibilityFeature(
                    icon: "eye.fill",
                    title: "Alto Contraste",
                    description: "Colores accesibles para todos"
                )
                
                AccessibilityFeature(
                    icon: "bolt.fill",
                    title: "Offline",
                    description: "Funciona sin conexión a internet"
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var readyPage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
                .accessibilityHidden(true)
            
            Text("¡Todo listo!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .accessibleTitle()
            
            Text("Comienza a explorar la tabla periódica")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Componentes
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(currentPage == index ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Página \(currentPage + 1) de 4")
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 0 {
                Button("Anterior") {
                    withAnimation {
                        currentPage -= 1
                    }
                }
                .buttonStyle(.bordered)
                .accessibleButton(label: "Anterior")
            }
            
            Spacer()
            
            Button(currentPage < 3 ? "Siguiente" : "Comenzar") {
                if currentPage < 3 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibleButton(label: currentPage < 3 ? "Siguiente" : "Comenzar a usar la aplicación")
        }
        .padding(.horizontal)
    }
    
    // MARK: - Funciones
    
    private func completeOnboarding() {
        withAnimation {
            progressManager.settings.completoOnboarding = true
            progressManager.guardarSettings()
        }
    }
}

// MARK: - Componentes Auxiliares

struct LanguageButton: View {
    let idioma: Idioma
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(idioma.nombre)
                    .font(.title3)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : ColorPalette.Sistema.fondoSecundario)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(.primary)
        .accessibleButton(
            label: idioma.nombre,
            hint: isSelected ? "Seleccionado" : "Toca para seleccionar"
        )
    }
}

struct AccessibilityFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .accessibleGroup(label: "\(title): \(description)")
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(ProgressManager.shared)
}
