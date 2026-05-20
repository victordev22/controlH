//
//  TokenManager.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation
import Security

class TokenManager {
    private static let jwtTokenKey = "com.controlh.jwttoken"

    // En iOS no hace falta inicializar un Context como en Android.
    // El Keychain está disponible globalmente en el sistema operativo.
    func initManager() {
        print("TokenManager: Sistema de llavero seguro iOS listo.")
    }

    static func saveToken( token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: jwtTokenKey,
            kSecValueData as String: data
        ]

        // Eliminamos si existía un token previo para evitar colisiones
        SecItemDelete(query as CFDictionary)

        // Insertamos el nuevo token cifrado
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("TokenManager: Token guardado de forma segura en Keychain.")
        }
    }

    static func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: jwtTokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(decoding: data, as: UTF8.self)
        }
        print("TokenManager: Token no encontrado o expirado.")
        return nil
    }

    static func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: jwtTokenKey
        ]
        SecItemDelete(query as CFDictionary)
        print("TokenManager: Token eliminado del Keychain.")
    }
}
