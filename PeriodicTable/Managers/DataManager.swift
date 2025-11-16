//
//  DataManager.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    // MARK: - Singleton
    static let shared = DataManager()
    
    // MARK: - Published Properties
    @Published var elementos: [Elemento] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var elementosPorFamilia: [FamiliaElemento: [Elemento]] {
        Dictionary(grouping: elementos, by: { $0.familia })
    }
    
    var elementosPorPeriodo: [Int: [Elemento]] {
        Dictionary(grouping: elementos, by: { $0.periodo })
    }
    
    // MARK: - Inicializador privado (Singleton)
    private init() {
        cargarElementos()
    }
    
    // MARK: - Cargar Datos
    func cargarElementos() {
        isLoading = true
        errorMessage = nil
        
        // Intentar cargar desde el archivo JSON
        guard let url = Bundle.main.url(forResource: "elementos", withExtension: "json") else {
            errorMessage = "No se encontró el archivo elementos.json"
            isLoading = false
            // Cargar datos de ejemplo si falla
            cargarDatosEjemplo()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            elementos = try decoder.decode([Elemento].self, from: data)
            isLoading = false
            print("✅ Cargados \(elementos.count) elementos correctamente")
        } catch {
            errorMessage = "Error al cargar elementos: \(error.localizedDescription)"
            isLoading = false
            // Cargar datos de ejemplo en caso de error
            cargarDatosEjemplo()
        }
    }
    
    // MARK: - Datos de Ejemplo (para desarrollo)
    private func cargarDatosEjemplo() {
        elementos = [
            Elemento.ejemploHidrogeno,
            // Helio
            Elemento(
                id: 2,
                simbolo: "He",
                nombreES: "Helio",
                nombreEN: "Helium",
                familia: .gasesNobles,
                periodo: 1,
                grupo: 18,
                masaAtomica: 4.003,
                estado25C: .gas,
                densidad: 0.0001785,
                puntoFusionC: -272.2,
                puntoEbullicionC: -268.93,
                configuracionElectronica: "1s²",
                electronegatividad: nil,
                usosES: ["Globos", "Helio líquido para enfriamiento", "Atmósferas protectoras"],
                usosEN: ["Balloons", "Liquid helium for cooling", "Protective atmospheres"],
                curiosidadesES: "El helio es el segundo elemento más abundante del universo después del hidrógeno."
            ),
            // Litio
            Elemento(
                id: 3,
                simbolo: "Li",
                nombreES: "Litio",
                nombreEN: "Lithium",
                familia: .metalesAlcalinos,
                periodo: 2,
                grupo: 1,
                masaAtomica: 6.94,
                estado25C: .solido,
                densidad: 0.534,
                puntoFusionC: 180.5,
                puntoEbullicionC: 1342,
                configuracionElectronica: "[He] 2s¹",
                electronegatividad: 0.98,
                usosES: ["Baterías recargables", "Medicamentos psiquiátricos", "Cerámica y vidrio"],
                usosEN: ["Rechargeable batteries", "Psychiatric medication", "Ceramics and glass"],
                curiosidadesES: "El litio es el metal sólido más ligero y el elemento sólido menos denso."
            )
        ]
        print("⚠️ Usando datos de ejemplo (\(elementos.count) elementos)")
    }
    
    // MARK: - Búsqueda y Filtros
    func buscarElemento(porID id: Int) -> Elemento? {
        return elementos.first { $0.id == id }
    }
    
    func buscarElemento(porSimbolo simbolo: String) -> Elemento? {
        return elementos.first { $0.simbolo.lowercased() == simbolo.lowercased() }
    }
    
    func buscarElementos(porNombre nombre: String, idioma: Idioma = .espanol) -> [Elemento] {
        let nombreBusqueda = nombre.lowercased()
        return elementos.filter { elemento in
            if idioma == .espanol {
                return elemento.nombreES.lowercased().contains(nombreBusqueda)
            } else {
                return elemento.nombreEN.lowercased().contains(nombreBusqueda)
            }
        }
    }
    
    func filtrarElementos(
        porFamilia familia: FamiliaElemento? = nil,
        porEstado estado: EstadoMateria? = nil,
        porPeriodo periodo: Int? = nil,
        porGrupo grupo: Int? = nil,
        soloMetales: Bool? = nil
    ) -> [Elemento] {
        var resultado = elementos
        
        if let familia = familia {
            resultado = resultado.filter { $0.familia == familia }
        }
        
        if let estado = estado {
            resultado = resultado.filter { $0.estado25C == estado }
        }
        
        if let periodo = periodo {
            resultado = resultado.filter { $0.periodo == periodo }
        }
        
        if let grupo = grupo {
            resultado = resultado.filter { $0.grupo == grupo }
        }
        
        if let soloMetales = soloMetales {
            resultado = resultado.filter { $0.esMetal == soloMetales }
        }
        
        return resultado
    }
    
    // MARK: - Elementos Aleatorios (para juegos)
    func elementosAleatorios(cantidad: Int) -> [Elemento] {
        return Array(elementos.shuffled().prefix(cantidad))
    }
    
    func elementoAleatorio() -> Elemento? {
        return elementos.randomElement()
    }
}
