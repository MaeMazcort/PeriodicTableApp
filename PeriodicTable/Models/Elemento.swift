//
//  Elemento.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation

struct Elemento: Identifiable, Codable, Hashable {
    // MARK: - Propiedades Básicas
    let id: Int // Número atómico (identificador único)
    let simbolo: String
    let nombreES: String
    let nombreEN: String
    
    // MARK: - Clasificación
    let familia: FamiliaElemento
    let periodo: Int
    let grupo: Int?
    
    // MARK: - Propiedades Físicas
    let masaAtomica: Double?
    let estado25C: EstadoMateria
    let densidad: Double? // g/cm³
    let puntoFusionC: Double?
    let puntoEbullicionC: Double?
    
    // MARK: - Propiedades Químicas
    let configuracionElectronica: String?
    let electronegatividad: Double? // Escala Pauling
    let radioAtomico: Double? // pm (picómetros)
    let energiaIonizacion: Double? // kJ/mol
    
    // MARK: - Información Educativa
    let usosES: [String]
    let usosEN: [String]
    let curiosidadesES: String?
    let curiosidadesEN: String?
    let seguridadES: String?
    let seguridadEN: String?
    
    // MARK: - Propiedades Computadas
    var esMetal: Bool {
        switch familia {
        case .metalesAlcalinos, .metalesAlcalinoterreos, .metalesTransicion,
             .lantanidos, .actinidos, .metalesPosTrans:
            return true
        case .metaloides, .noMetales, .halogenos, .gasesNobles:
            return false
        }
    }
    
    var nombreLocalizado: String {
        // Por ahora retorna español, se extenderá con LocalizationManager
        return nombreES
    }
    
    var usosLocalizados: [String] {
        return usosES
    }
    
    // MARK: - Inicializador con valores por defecto
    init(
        id: Int,
        simbolo: String,
        nombreES: String,
        nombreEN: String,
        familia: FamiliaElemento,
        periodo: Int,
        grupo: Int? = nil,
        masaAtomica: Double? = nil,
        estado25C: EstadoMateria,
        densidad: Double? = nil,
        puntoFusionC: Double? = nil,
        puntoEbullicionC: Double? = nil,
        configuracionElectronica: String? = nil,
        electronegatividad: Double? = nil,
        radioAtomico: Double? = nil,
        energiaIonizacion: Double? = nil,
        usosES: [String] = [],
        usosEN: [String] = [],
        curiosidadesES: String? = nil,
        curiosidadesEN: String? = nil,
        seguridadES: String? = nil,
        seguridadEN: String? = nil
    ) {
        self.id = id
        self.simbolo = simbolo
        self.nombreES = nombreES
        self.nombreEN = nombreEN
        self.familia = familia
        self.periodo = periodo
        self.grupo = grupo
        self.masaAtomica = masaAtomica
        self.estado25C = estado25C
        self.densidad = densidad
        self.puntoFusionC = puntoFusionC
        self.puntoEbullicionC = puntoEbullicionC
        self.configuracionElectronica = configuracionElectronica
        self.electronegatividad = electronegatividad
        self.radioAtomico = radioAtomico
        self.energiaIonizacion = energiaIonizacion
        self.usosES = usosES
        self.usosEN = usosEN
        self.curiosidadesES = curiosidadesES
        self.curiosidadesEN = curiosidadesEN
        self.seguridadES = seguridadES
        self.seguridadEN = seguridadEN
    }
}

// MARK: - Enums Auxiliares

enum FamiliaElemento: String, Codable, CaseIterable {
    case metalesAlcalinos = "Metales Alcalinos"
    case metalesAlcalinoterreos = "Metales Alcalinotérreos"
    case metalesTransicion = "Metales de Transición"
    case metalesPosTrans = "Metales del Bloque P"
    case lantanidos = "Lantánidos"
    case actinidos = "Actínidos"
    case metaloides = "Metaloides"
    case noMetales = "No Metales"
    case halogenos = "Halógenos"
    case gasesNobles = "Gases Nobles"
    
    var colorClave: String {
        switch self {
        case .metalesAlcalinos: return "FamiliaAlcalinos"
        case .metalesAlcalinoterreos: return "FamiliaAlcalinoterreos"
        case .metalesTransicion: return "FamiliaTransicion"
        case .metalesPosTrans: return "FamiliaPosTrans"
        case .lantanidos: return "FamiliaLantanidos"
        case .actinidos: return "FamiliaActinidos"
        case .metaloides: return "FamiliaMetaloides"
        case .noMetales: return "FamiliaNoMetales"
        case .halogenos: return "FamiliaHalogenos"
        case .gasesNobles: return "FamiliaGasesNobles"
        }
    }
}

enum EstadoMateria: String, Codable {
    case solido = "Sólido"
    case liquido = "Líquido"
    case gas = "Gas"
    case desconocido = "Desconocido"
    
    var icono: String {
        switch self {
        case .solido: return "cube.fill"
        case .liquido: return "drop.fill"
        case .gas: return "cloud.fill"
        case .desconocido: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Extensión para datos de ejemplo
extension Elemento {
    static let ejemploHidrogeno = Elemento(
        id: 1,
        simbolo: "H",
        nombreES: "Hidrógeno",
        nombreEN: "Hydrogen",
        familia: .noMetales,
        periodo: 1,
        grupo: 1,
        masaAtomica: 1.008,
        estado25C: .gas,
        densidad: 0.00008988,
        puntoFusionC: -259.16,
        puntoEbullicionC: -252.87,
        configuracionElectronica: "1s¹",
        electronegatividad: 2.20,
        radioAtomico: 53,
        energiaIonizacion: 1312,
        usosES: ["Combustible para cohetes", "Producción de amoníaco", "Refinación de petróleo"],
        usosEN: ["Rocket fuel", "Ammonia production", "Petroleum refining"],
        curiosidadesES: "El hidrógeno es el elemento más abundante del universo, constituye aproximadamente el 75% de toda la materia.",
        curiosidadesEN: "Hydrogen is the most abundant element in the universe, making up about 75% of all matter."
    )
    
    static let ejemplos: [Elemento] = [ejemploHidrogeno]
}
