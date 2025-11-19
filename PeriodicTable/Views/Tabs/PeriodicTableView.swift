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

struct ElementCard: View {
    let elemento: Elemento
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(elemento.id)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(ColorPalette.colorParaFamilia(elemento.familia))
            
            Text(elemento.simbolo)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(ColorPalette.colorParaFamilia(elemento.familia))
            
            Text(elemento.nombreLocalizado)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(ColorPalette.colorParaFamilia(elemento.familia))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(width: 70, height: 70)
        .background(ColorPalette.colorParaFamilia(elemento.familia).opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    PeriodicTableView()
}
