//
//  AuthInterceptor.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation

class AuthInterceptor {
    static let shared = AuthInterceptor()
    private init() {}

    /// Modifica una URLRequest mapeando el comportamiento del originalRequest.newBuilder() de OkHttp
    func adapt(_ request: URLRequest) -> URLRequest {
        var modifiedRequest = request

        // Obtenemos el token almacenado de tu llavero seguro o gestor
        if let token = TokenManager.getToken() {
            // Equivale exactamente a requestBuilder.header("Authorization", "Bearer $it")
            modifiedRequest.setValue("Bearer (token)", forHTTPHeaderField: "Authorization")
        }

        return modifiedRequest
    }
}
