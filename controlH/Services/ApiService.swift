//
//  ApiService.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation

class ApiService {
    // Instancia compartida (Singleton) para usarla en toda la app
    static let shared = ApiService()
    
    // Cambia esto por la URL real de tu backend o tus constantes
    private let baseURL = "https://tu-api-backend.com"
    
    // Aquí puedes guardar el token JWT en memoria tras el login
    var jwtToken: String? = nil
    
    private init() {} // Evita que se creen otras instancias
    
    // MARK: - Helper para peticiones reutilizables (Sustituye a los interceptores de OkHttp)
    private func makeRequest(path: String, method: String, body: Data? = nil, queryParams: [String: String]? = nil) -> URLRequest {
        var urlString = baseURL + (path.hasPrefix("/") ? "" : "/") + path
        
        // Manejo de Parámetros Query (como los @Query de Retrofit)
        if let queryParams = queryParams, !queryParams.isEmpty {
            var components = URLComponents(string: urlString)
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            if let updatedUrl = components?.url?.absoluteString {
                urlString = updatedUrl
            }
        }
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue("application" + "/json", forHTTPHeaderField: "Content-Type")
        
        // Adjuntar token de forma automática si existe (Mismo comportamiento de tu AuthInterceptor)
        if let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        return request
    }
    
    // MARK: - 1. SSH / API GENERAL
    func sendCommand(command: String) async throws {
        let request = makeRequest(path: "api/ssh/execute", method: "GET", queryParams: ["command": command])
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "ServerEror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error ejecutando comando SSH"])
        }
    }
    
    // MARK: - 2. AUTH SERVICE (Login, Registro, Usuarios)
    func login(requestData: LoginRequest) async throws -> JwtResponse {
        let body = try JSONEncoder().encode(requestData)
        let request = makeRequest(path: "/auth/signin", method: "POST", body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        // Comprobar estado HTTP antes de parsear
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Credenciales inválidas"])
        }
        
        let jwtResponse = try JSONDecoder().decode(JwtResponse.self, from: data)
        // Guardamos el token para futuras peticiones automáticamente
        self.jwtToken = jwtResponse.token
        return jwtResponse
    }
    
    func signup(requestData: SignupRequest) async throws -> String {
        let body = try JSONEncoder().encode(requestData)
        let request = makeRequest(path: "/auth/signup", method: "POST", body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error en el registro"])
        }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func getCurrentUser() async throws -> User {
        let request = makeRequest(path: "/auth/me", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func getRawCurrentUserJson() async throws -> UserFull {
        let request = makeRequest(path: "/auth/me", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // En Swift configuramos el decoder para pasar de snake_case a camelCase automáticamente
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(UserFull.self, from: data)
    }
    
    func updateUser(id: Int, user: UserFull) async throws -> MessageResponse {
        let body = try JSONEncoder().encode(user)
        let request = makeRequest(path: "/update/\(id)", method: "PUT", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
    
    func updateUserRole(email: String, roleRequest: RoleUpdateRequest) async throws -> MessageResponse {
        let body = try JSONEncoder().encode(roleRequest)
        let request = makeRequest(path: "/update/role/\(email)", method: "PUT", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }
    
    func deleteUser(id: Int64) async throws {
        let request = makeRequest(path: "update/delete/\(id)", method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "DeleteError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo eliminar el usuario"])
        }
    }
    
    // MARK: - 3. CONTROL SERVICE
    func getHoras() async throws -> [Horas] {
        let request = makeRequest(path: "/control/wines", method: "GET") // Reemplacé PATH_WINES por string de ejemplo
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        // Estrategia nativa de Swift para leer fechas en formato ISO8601 estándar automáticamente
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Horas].self, from: data)
    }
    
    func getAllUsersFull() async throws -> [UserFull] {
        let request = makeRequest(path: "/auth/admin/list", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([UserFull].self, from: data)
    }
    
    func getHoraById(id: Int) async throws -> Horas {
        let request = makeRequest(path: "control/find/\(id)", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Horas.self, from: data)
    }
    
    // MARK: - 4. NOVU API SERVICE
    func updateSubscriberCredentials(apiKey: String, subscriberId: String, jsonRawBody: Data) async throws {
        var request = URLRequest(url: URL(string: "https://api.novu.co/v1/subscribers/\(subscriberId)/credentials")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonRawBody
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "NovuError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error actualizando credenciales Novu"])
        }
    }
}
