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
    let id: Int
    var nickname: String
    var email: String
    let password: String?
    let onControl: String
    let ofControl: String
    var roles: [Role]

    enum CodingKeys: String, CodingKey {
        case id, nickname, email, password, roles
        case onControl = "on_control"
        case ofControl = "of_control"
    }
}
