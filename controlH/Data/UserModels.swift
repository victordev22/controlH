//
//  UserModels.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation

struct Role: Codable {
    let erole: String

    // Esto mapea la propiedad 'erole' de Swift a 'erole' en el JSON.
    // Si en el JSON se llama igual, simplemente se declara así:
    enum CodingKeys: String, CodingKey {
        case erole = "erole"
    }
}

struct RoleUpdateRequest: Codable {
    let newRoleId: Int
}

struct User: Codable {
    let nickname: String
    let email: String
    let roles: [Role]
    
    // Si tuvieras que usar on_control y of_control en el futuro:
    // let onControl: String
    // let ofControl: String
}

struct UserFull: Codable, Identifiable {
    let id: Int // Al tener una propiedad 'id', podemos agregar 'Identifiable' para usarlo fácil en listas de SwiftUI
    let nickname: String
    let email: String
    let password: String
    let onControl: String
    let ofControl: String

    // Mapeamos los nombres con guion bajo del JSON (on_control) a camelCase de Swift (onControl)
    enum CodingKeys: String, CodingKey {
        case id, nickname, email, password
        case onControl = "on_control"
        case ofControl = "of_control"
        case roles
    }
}
