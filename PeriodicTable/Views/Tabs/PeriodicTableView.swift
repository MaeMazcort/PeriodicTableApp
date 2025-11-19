import SwiftUI

struct PeriodicTableView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            if dataManager.isLoading {
                SwiftUI.ProgressView("Cargando elementos...")
                    .padding()
                    .onAppear {
                        // Debug: Print elements 21-30 to see their periodo and grupo values
                        let elements21to30 = dataManager.elementos.filter { $0.id >= 21 && $0.id <= 30 }
                        for elemento in elements21to30 {
                            print("Elemento \(elemento.id) (\(elemento.simbolo)): periodo=\(elemento.periodo), grupo=\(elemento.grupo ?? -1)")
                        }
                    }
            } else if let errorMessage = dataManager.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                VStack(spacing: 4) {
                    // Debug: Print total elements loaded
                    let _ = print("📊 Total elementos cargados: \(dataManager.elementos.count)")
                    let _ = dataManager.elementos.filter { $0.id >= 21 && $0.id <= 25 }.map { elemento in
                        print("🔍 Elemento \(elemento.id) (\(elemento.simbolo)): periodo=\(elemento.periodo), grupo=\(elemento.grupo ?? -999)")
                    }
                    
                    // Rows 1-7
                    ForEach(0..<7) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<18) { col in
                                if let elemento = getElement(periodo: row + 1, grupo: col + 1) {
                                    ElementCard(elemento: elemento)
                                } else {
                                    // Espacio vacío transparente del mismo tamaño
                                    Color.clear
                                        .frame(width: 70, height: 70)
                                }
                            }
                        }
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // Lantánidos y Actínidos
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            ForEach(getLanthanides()) { elemento in
                                ElementCard(elemento: elemento)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            ForEach(getActinides()) { elemento in
                                ElementCard(elemento: elemento)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    func getElement(periodo: Int, grupo: Int) -> Elemento? {
        // Adjust for special cases in periodic table layout
        let elemento = dataManager.elementos.first { elemento in
            elemento.periodo == periodo && elemento.grupo == grupo
        }
        
        // Debug: Print what we're looking for and what we found
        if periodo == 4 && grupo >= 3 && grupo <= 7 {
            if let found = elemento {
                print("✅ Encontrado en periodo \(periodo), grupo \(grupo): \(found.simbolo)")
            } else {
                print("❌ NO encontrado en periodo \(periodo), grupo \(grupo)")
            }
        }
        
        return elemento
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

struct ElementCard: View {
    let elemento: Elemento
    
    var body: some View {
        // Temporary: Use Alcalinoterreos color for transition metals until FamiliaTransicion is added to Assets
        let elementColor: Color = {
            if elemento.familia == .metalesTransicion {
                return ColorPalette.colorParaFamilia(.metalesAlcalinoterreos)
            }
            return ColorPalette.colorParaFamilia(elemento.familia)
        }()
        
        VStack(spacing: 2) {
            Text("\(elemento.id)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(elementColor)
            
            Text(elemento.simbolo)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(elementColor)
            
            Text(elemento.nombreLocalizado)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(elementColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: 70, height: 70)
        .background(elementColor.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    PeriodicTableView()
}
