//
//  Horas.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation

struct Horas: Codable, Identifiable {
    let id: Int
    let user: String
    let horaEncendido: Date?
    let horaApagado: Date?
    let minutosInactivo: Int
    let listaApps: String?

    enum CodingKeys: String, CodingKey {
        case id, user, minutosInactivo, listaApps
        case horaEncendido = "horaEncendido"
        case horaApagado   = "horaApagado"
    }
}
