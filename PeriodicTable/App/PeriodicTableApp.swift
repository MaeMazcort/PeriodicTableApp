//
//  PeriodicTableApp.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import SwiftUI
import Combine

@main
struct PeriodicTableApp: App {
    // MARK: - State Objects
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var ttsManager = TTSManager.shared
    
    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(progressManager)
                .environmentObject(ttsManager)
                .preferredColorScheme(preferredColorScheme)
        }
    }
    
    // MARK: - Computed Properties
    private var preferredColorScheme: ColorScheme? {
        switch progressManager.settings.temaVisual {
        case .claro:
            return .light
        case .oscuro:
            return .dark
        case .sistema:
            return nil
        }
    }
}

// MARK: - ContentView (Vista Principal)
struct ContentView: View {
    @EnvironmentObject var progressManager: ProgressManager
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        Group {
            if !progressManager.settings.completoOnboarding {
                OnboardingView()
            } else {
                mainTabView
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            PeriodicTableView()
                .tabItem {
                    Label("Tabla", systemImage: "square.grid.3x3.fill")
                }
                .tag(Tab.table)
            
            SearchView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
            
            GamesHubView()
                .tabItem {
                    Label("Juegos", systemImage: "gamecontroller.fill")
                }
                .tag(Tab.games)
            
            ProgressView()
                .tabItem {
                    Label("Progreso", systemImage: "chart.bar.fill")
                }
                .tag(Tab.progress)
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .accentColor(ColorPalette.Sistema.primario)
    }
    
    // MARK: - Tab Enum
    enum Tab {
        case home, table, search, games, progress, settings
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
        .environmentObject(ProgressManager.shared)
        .environmentObject(TTSManager.shared)
}
