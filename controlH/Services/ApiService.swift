//
//  ApiService.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation

class ApiService {
    static let shared = ApiService()
    var jwtToken: String? = nil

    private init() {}

    // MARK: - Helper (acepta baseURL por parámetro para soportar múltiples microservicios)
    private func makeRequest(baseURL: String, path: String, method: String,
                             body: Data? = nil,
                             queryParams: [String: String]? = nil) -> URLRequest {
        let cleanBase = baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        var urlString = cleanBase + cleanPath

        if let params = queryParams, !params.isEmpty {
            var components = URLComponents(string: urlString)
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlString = components?.url?.absoluteString ?? urlString
        }

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = jwtToken ?? TokenManager.getToken()
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = body
        return request
    }

    // MARK: - AUTH SERVICE (auth.meta4bim.com)

    func login(requestData: LoginRequest) async throws -> JwtResponse {
        let body = try JSONEncoder().encode(requestData)
        let request = makeRequest(baseURL: Constants.baseAuth, path: "auth/signin", method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "AuthError", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "Credenciales inválidas"])
        }
        let jwtResponse = try JSONDecoder().decode(JwtResponse.self, from: data)
        self.jwtToken = jwtResponse.token
        return jwtResponse
    }

    func signup(requestData: SignupRequest) async throws -> String {
        let body = try JSONEncoder().encode(requestData)
        let request = makeRequest(baseURL: Constants.baseAuth, path: "auth/signup", method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "AuthError", code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "Error en el registro"])
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    func getCurrentUser() async throws -> User {
        let request = makeRequest(baseURL: Constants.baseAuth, path: "auth/me", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(User.self, from: data)
    }

    func getRawCurrentUserJson() async throws -> UserFull {
        let request = makeRequest(baseURL: Constants.baseAuth, path: "auth/me", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(UserFull.self, from: data)
    }

    func getAllUsersFull() async throws -> [UserFull] {
        let request = makeRequest(baseURL: Constants.baseAuth, path: Constants.pathUser, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([UserFull].self, from: data)
    }

    func updateUser(id: Int, user: UserFull) async throws -> MessageResponse {
        let body = try JSONEncoder().encode(user)
        let request = makeRequest(baseURL: Constants.baseAuth, path: "update/\(id)", method: "PUT", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }

    func updateUserRole(email: String, roleRequest: RoleUpdateRequest) async throws -> MessageResponse {
        let body = try JSONEncoder().encode(roleRequest)
        let request = makeRequest(baseURL: Constants.baseAuth, path: "update/role/\(email)", method: "PUT", body: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MessageResponse.self, from: data)
    }

    func deleteUser(id: Int64) async throws {
        let request = makeRequest(baseURL: Constants.baseAuth, path: "update/delete/\(id)", method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "DeleteError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No se pudo eliminar el usuario"])
        }
    }

    // MARK: - CONTROL SERVICE (control.meta4bim.com)

    func getHoras() async throws -> [Horas] {
        let request = makeRequest(baseURL: Constants.baseURL, path: Constants.pathHoras, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try ApiService.springBootDecoder.decode([Horas].self, from: data)
    }

    // Decoder robusto para fechas de Spring Boot: soporta ISO8601 con/sin ms, con/sin timezone
    static var springBootDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let isoFull   = ISO8601DateFormatter()
        isoFull.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoBasic  = ISO8601DateFormatter()
        isoBasic.formatOptions = [.withInternetDateTime]
        let noTzMs = makeDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS")
        let noTz   = makeDateFormatter("yyyy-MM-dd'T'HH:mm:ss")
        let spaced = makeDateFormatter("yyyy-MM-dd HH:mm:ss")

        decoder.dateDecodingStrategy = .custom { dec in
            let c = try dec.singleValueContainer()
            let s = try c.decode(String.self)
            if let d = isoFull.date(from: s)  { return d }
            if let d = isoBasic.date(from: s)  { return d }
            if let d = noTzMs.date(from: s)    { return d }
            if let d = noTz.date(from: s)      { return d }
            if let d = spaced.date(from: s)    { return d }
            throw DecodingError.dataCorrupted(
                .init(codingPath: dec.codingPath, debugDescription: "Formato de fecha no reconocido: \(s)")
            )
        }
        return decoder
    }

    private static func makeDateFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = format
        return f
    }

    func getHoraById(id: Int) async throws -> Horas {
        let request = makeRequest(baseURL: Constants.baseURL, path: "control/find/\(id)", method: "GET")
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Horas.self, from: data)
    }

    // MARK: - SSH SERVICE
    func sendCommand(command: String) async throws {
        let request = makeRequest(baseURL: Constants.baseSsh, path: "", method: "POST",
                                  queryParams: ["command": command])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "SshError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Error ejecutando comando SSH"])
        }
    }

    // MARK: - NOVU API SERVICE
    func updateSubscriberCredentials(apiKey: String, subscriberId: String, jsonRawBody: Data) async throws {
        var request = URLRequest(url: URL(string: "https://api.novu.co/v1/subscribers/\(subscriberId)/credentials")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonRawBody
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "NovuError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Error actualizando credenciales Novu"])
        }
    }
}
