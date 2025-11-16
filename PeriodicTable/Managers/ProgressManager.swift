//
//  ProgressManager.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation
import Combine

@MainActor
class ProgressManager: ObservableObject {
    // MARK: - Singleton
    static let shared = ProgressManager()
    
    // MARK: - Keys para UserDefaults
    private enum Keys {
        static let progreso = "usuario_progreso"
        static let settings = "user_settings"
    }
    
    // MARK: - Published Properties
    @Published var progreso: UsuarioProgreso
    @Published var settings: UserSettings
    
    // MARK: - Inicializador
    private init() {
        // Cargar progreso guardado o crear uno nuevo
        if let data = UserDefaults.standard.data(forKey: Keys.progreso),
           let decodedProgreso = try? JSONDecoder().decode(UsuarioProgreso.self, from: data) {
            self.progreso = decodedProgreso
        } else {
            self.progreso = UsuarioProgreso()
        }
        
        // Cargar configuración guardada o crear una nueva
        if let data = UserDefaults.standard.data(forKey: Keys.settings),
           let decodedSettings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            self.settings = decodedSettings
        } else {
            self.settings = UserSettings()
        }
        
        // Registrar la fecha de primera apertura si no existe
        if settings.fechaPrimeraApertura == nil {
            settings.fechaPrimeraApertura = Date()
            guardarSettings()
        }
        
        // Actualizar racha
        actualizarRacha()
    }
    
    // MARK: - Guardar/Cargar
    func guardarProgreso() {
        if let encoded = try? JSONEncoder().encode(progreso) {
            UserDefaults.standard.set(encoded, forKey: Keys.progreso)
            print("✅ Progreso guardado")
        }
    }
    
    func guardarSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: Keys.settings)
            print("✅ Configuración guardada")
        }
    }
    
    func guardarTodo() {
        guardarProgreso()
        guardarSettings()
    }
    
    // MARK: - Gestión de Favoritos
    func agregarFavorito(_ elementoID: Int) {
        progreso.agregarFavorito(elementoID)
        guardarProgreso()
    }
    
    func quitarFavorito(_ elementoID: Int) {
        progreso.quitarFavorito(elementoID)
        guardarProgreso()
    }
    
    func esFavorito(_ elementoID: Int) -> Bool {
        return progreso.esFavorito(elementoID)
    }
    
    func toggleFavorito(_ elementoID: Int) {
        if esFavorito(elementoID) {
            quitarFavorito(elementoID)
        } else {
            agregarFavorito(elementoID)
        }
    }
    
    // MARK: - Gestión de Aprendizaje
    func registrarVistaElemento(_ elementoID: Int) {
        var estado = progreso.elementosEstudiados[elementoID] ?? EstadoAprendizaje()
        estado.registrarVista()
        progreso.elementosEstudiados[elementoID] = estado
        guardarProgreso()
    }
    
    func registrarRespuesta(elementoID: Int, correcta: Bool) {
        var estado = progreso.elementosEstudiados[elementoID] ?? EstadoAprendizaje()
        estado.registrarRespuesta(correcta: correcta)
        progreso.elementosEstudiados[elementoID] = estado
        
        progreso.registrarRespuesta(correcta: correcta)
        guardarProgreso()
    }
    
    func estadoAprendizaje(de elementoID: Int) -> EstadoAprendizaje? {
        return progreso.elementosEstudiados[elementoID]
    }
    
    func nivelDominio(de elementoID: Int) -> NivelDominio {
        return progreso.elementosEstudiados[elementoID]?.nivelDominio ?? .nuevo
    }
    
    // MARK: - Gestión de Sesiones de Juego
    func registrarSesionJuego(_ sesion: SesionJuego) {
        progreso.sesionesJuego.append(sesion)
        progreso.tiempoTotalEstudioMinutos += sesion.duracionSegundos / 60
        guardarProgreso()
    }
    
    func obtenerSesiones(tipo: TipoJuego? = nil, limite: Int? = nil) -> [SesionJuego] {
        var sesiones = progreso.sesionesJuego
        
        if let tipo = tipo {
            sesiones = sesiones.filter { $0.tipoJuego == tipo }
        }
        
        sesiones = sesiones.sorted { $0.fecha > $1.fecha }
        
        if let limite = limite {
            sesiones = Array(sesiones.prefix(limite))
        }
        
        return sesiones
    }
    
    // MARK: - Rachas
    func actualizarRacha() {
        let calendario = Calendar.current
        let hoy = calendario.startOfDay(for: Date())
        
        guard let ultimaFecha = progreso.ultimaFechaEstudio else {
            // Primera vez estudiando
            progreso.ultimaFechaEstudio = Date()
            progreso.rachaActual = 1
            progreso.mejorRacha = 1
            guardarProgreso()
            return
        }
        
        let ultimoDia = calendario.startOfDay(for: ultimaFecha)
        let diasDiferencia = calendario.dateComponents([.day], from: ultimoDia, to: hoy).day ?? 0
        
        if diasDiferencia == 0 {
            // Mismo día, no hacer nada
            return
        } else if diasDiferencia == 1 {
            // Día consecutivo
            progreso.rachaActual += 1
            if progreso.rachaActual > progreso.mejorRacha {
                progreso.mejorRacha = progreso.rachaActual
            }
        } else {
            // Se rompió la racha
            progreso.rachaActual = 1
        }
        
        progreso.ultimaFechaEstudio = Date()
        guardarProgreso()
    }
    
    // MARK: - Estadísticas
    func estadisticasPorJuego() -> [TipoJuego: (partidas: Int, precision: Double)] {
        var stats: [TipoJuego: (partidas: Int, precision: Double)] = [:]
        
        for tipo in TipoJuego.allCases {
            let sesiones = obtenerSesiones(tipo: tipo)
            let totalPartidas = sesiones.count
            let precisionPromedio = sesiones.isEmpty ? 0 : sesiones.map { $0.porcentajeAcierto }.reduce(0, +) / Double(sesiones.count)
            stats[tipo] = (partidas: totalPartidas, precision: precisionPromedio)
        }
        
        return stats
    }
    
    func elementosPorDominio() -> [NivelDominio: Int] {
        var conteo: [NivelDominio: Int] = [:]
        
        for nivel in [NivelDominio.nuevo, .aprendiendo, .enProgreso, .dominado] {
            conteo[nivel] = progreso.elementosEstudiados.values.filter { $0.nivelDominio == nivel }.count
        }
        
        return conteo
    }
    
    // MARK: - Resetear Datos
    func resetearProgreso() {
        progreso = UsuarioProgreso()
        guardarProgreso()
    }
    
    func resetearSettings() {
        let fechaPrimera = settings.fechaPrimeraApertura
        settings = UserSettings()
        settings.fechaPrimeraApertura = fechaPrimera
        guardarSettings()
    }
    
    func resetearTodo() {
        resetearProgreso()
        resetearSettings()
    }
    
    // MARK: - Exportar/Importar (para futuro)
    func exportarProgreso() -> Data? {
        return try? JSONEncoder().encode(progreso)
    }
    
    func importarProgreso(data: Data) -> Bool {
        if let nuevoProgreso = try? JSONDecoder().decode(UsuarioProgreso.self, from: data) {
            progreso = nuevoProgreso
            guardarProgreso()
            return true
        }
        return false
    }
}
