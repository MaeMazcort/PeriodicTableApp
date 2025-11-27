//
//  FiltroElemento.swift
//  PeriodicTable
//
//  Created by Maeva Mazadiego
//

import Foundation

enum FiltroElemento: String, CaseIterable {
    case todos = "Todos"
    case metales = "Metales"
    case noMetales = "No Metales"
    case gases = "Gases"
    case liquidos = "Líquidos"
    case solidos = "Sólidos"
    
    var nombre: String { rawValue }
}
