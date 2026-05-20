//
//  AuthModels.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation

// LoginRequest
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// SignupRequest
struct SignupRequest: Codable {
    let nickname: String
    let email: String
    let password: String
}

// JwtResponse
struct JwtResponse: Codable {
    let token: String
    let email: String
    let nickname: String
    let roles: Set<String>
}

// MessageResponse
struct MessageResponse: Codable {
    let message: String
}
