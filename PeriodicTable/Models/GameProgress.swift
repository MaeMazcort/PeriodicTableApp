//
//  GameProgress.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation

// MARK: - Progreso General del Usuario
struct UsuarioProgreso: Codable {
    var elementosFavoritos: Set<Int> = [] // IDs de elementos
    var elementosEstudiados: [Int: EstadoAprendizaje] = [:] // ID -> Estado
    var sesionesJuego: [SesionJuego] = []
    var logrosDesbloqueados: Set<String> = []
    var rachaActual: Int = 0
    var mejorRacha: Int = 0
    var ultimaFechaEstudio: Date?
    
    // Estadísticas globales
    var totalRespuestasCorrectas: Int = 0
    var totalRespuestas: Int = 0
    var tiempoTotalEstudioMinutos: Int = 0
    
    var porcentajePrecision: Double {
        guard totalRespuestas > 0 else { return 0 }
        return (Double(totalRespuestasCorrectas) / Double(totalRespuestas)) * 100
    }
    
    mutating func agregarFavorito(_ elementoID: Int) {
        elementosFavoritos.insert(elementoID)
    }
    
    mutating func quitarFavorito(_ elementoID: Int) {
        elementosFavoritos.remove(elementoID)
    }
    
    func esFavorito(_ elementoID: Int) -> Bool {
        return elementosFavoritos.contains(elementoID)
    }
    
    mutating func registrarRespuesta(correcta: Bool) {
        totalRespuestas += 1
        if correcta {
            totalRespuestasCorrectas += 1
        }
    }
}

// MARK: - Estado de Aprendizaje por Elemento
struct EstadoAprendizaje: Codable {
    var vecesVisto: Int = 0
    var vecesAcertado: Int = 0
    var vecesFallado: Int = 0
    var ultimaRevision: Date?
    var proximaRevision: Date?
    var nivelDominio: NivelDominio = .nuevo
    
    var porcentajeAcierto: Double {
        let total = vecesAcertado + vecesFallado
        guard total > 0 else { return 0 }
        return (Double(vecesAcertado) / Double(total)) * 100
    }
    
    mutating func registrarVista() {
        vecesVisto += 1
        ultimaRevision = Date()
    }
    
    mutating func registrarRespuesta(correcta: Bool) {
        if correcta {
            vecesAcertado += 1
        } else {
            vecesFallado += 1
        }
        actualizarNivelDominio()
        calcularProximaRevision()
    }
    
    private mutating func actualizarNivelDominio() {
        let porcentaje = porcentajeAcierto
        if vecesAcertado >= 5 && porcentaje >= 80 {
            nivelDominio = .dominado
        } else if vecesAcertado >= 3 && porcentaje >= 60 {
            nivelDominio = .enProgreso
        } else if vecesVisto > 0 {
            nivelDominio = .aprendiendo
        }
    }
    
    private mutating func calcularProximaRevision() {
        // Algoritmo simple de repetición espaciada
        let intervalo: TimeInterval
        switch nivelDominio {
        case .nuevo:
            intervalo = 0 // Inmediato
        case .aprendiendo:
            intervalo = 24 * 60 * 60 // 1 día
        case .enProgreso:
            intervalo = 3 * 24 * 60 * 60 // 3 días
        case .dominado:
            intervalo = 7 * 24 * 60 * 60 // 7 días
        }
        proximaRevision = Date().addingTimeInterval(intervalo)
    }
}

enum NivelDominio: String, Codable {
    case nuevo = "Nuevo"
    case aprendiendo = "Aprendiendo"
    case enProgreso = "En Progreso"
    case dominado = "Dominado"
    
    var color: String {
        switch self {
        case .nuevo: return "gray"
        case .aprendiendo: return "yellow"
        case .enProgreso: return "orange"
        case .dominado: return "green"
        }
    }
    
    var icono: String {
        switch self {
        case .nuevo: return "circle"
        case .aprendiendo: return "circle.lefthalf.filled"
        case .enProgreso: return "circle.righthalf.filled"
        case .dominado: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Sesión de Juego
struct SesionJuego: Codable, Identifiable {
    let id: UUID
    let tipoJuego: TipoJuego
    let fecha: Date
    let duracionSegundos: Int
    let respuestasCorrectas: Int
    let respuestasTotales: Int
    let puntuacion: Int
    
    var porcentajeAcierto: Double {
        guard respuestasTotales > 0 else { return 0 }
        return (Double(respuestasCorrectas) / Double(respuestasTotales)) * 100
    }
    
    init(
        id: UUID = UUID(),
        tipoJuego: TipoJuego,
        fecha: Date = Date(),
        duracionSegundos: Int,
        respuestasCorrectas: Int,
        respuestasTotales: Int,
        puntuacion: Int
    ) {
        self.id = id
        self.tipoJuego = tipoJuego
        self.fecha = fecha
        self.duracionSegundos = duracionSegundos
        self.respuestasCorrectas = respuestasCorrectas
        self.respuestasTotales = respuestasTotales
        self.puntuacion = puntuacion
    }
}

// MARK: - Tipos de Juego
enum TipoJuego: String, Codable, CaseIterable, Identifiable {
    case flashcards = "Flashcards"
    case quiz = "Quiz"
    case bingo = "Bingo"
    case mapaPorFamilias = "Mapa por Familias"
    case adivinaPropiedad = "Adivina la Propiedad"
    case parejas = "Parejas"
    case retoRelampago = "Reto Relámpago"
    
    var id: String { rawValue }
    
    var nombre: String {
        return self.rawValue
    }
    
    var icono: String {
        switch self {
        case .flashcards: return "rectangle.stack.fill"
        case .quiz: return "questionmark.circle.fill"
        case .bingo: return "grid.circle.fill"
        case .mapaPorFamilias: return "square.grid.3x3.fill"
        case .adivinaPropiedad: return "lightbulb.fill"
        case .parejas: return "square.on.square"
        case .retoRelampago: return "bolt.fill"
        }
    }
    
    var descripcion: String {
        switch self {
        case .flashcards:
            return "Aprende con tarjetas de repetición espaciada"
        case .quiz:
            return "Pon a prueba tus conocimientos con preguntas de opción múltiple"
        case .bingo:
            return "Completa tu cartón de elementos"
        case .mapaPorFamilias:
            return "Clasifica elementos por su familia química"
        case .adivinaPropiedad:
            return "Estima propiedades de los elementos"
        case .parejas:
            return "Encuentra pares de símbolos y nombres"
        case .retoRelampago:
            return "Responde todo lo que puedas en 60 segundos"
        }
    }
    
    var duracionEstimadaMinutos: Int {
        switch self {
        case .flashcards: return 10
        case .quiz: return 5
        case .bingo: return 15
        case .mapaPorFamilias: return 8
        case .adivinaPropiedad: return 7
        case .parejas: return 5
        case .retoRelampago: return 1
        }
    }
}

// MARK: - Logros
struct Logro: Identifiable, Codable {
    let id: String
    let nombre: String
    let descripcion: String
    let icono: String
    let condicion: CondicionLogro
    var desbloqueado: Bool = false
    var fechaDesbloqueo: Date?
    
    enum CondicionLogro: Codable {
        case elementosDominados(cantidad: Int)
        case respuestasCorrectas(cantidad: Int)
        case rachaEstudio(dias: Int)
        case completarFamilia(familia: FamiliaElemento)
        case completarJuego(tipo: TipoJuego, veces: Int)
    }
}
