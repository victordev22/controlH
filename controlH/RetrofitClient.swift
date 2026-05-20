//
//  RetrofitClient.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation

class RetrofitClient: NSObject, URLSessionDelegate {
    static let shared = RetrofitClient()
    
    private var urlSession: URLSession!
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        // Equivalente a agregar tus interceptores de log y headers
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        // Vinculamos el delegado para interceptar el handshake SSL
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    /// Realiza peticiones HTTP inyectando dinámicamente el token (Igual a tu AuthInterceptor)
    func request(for urlString: String, method: String = "GET", body: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        // Inyección automática del TokenManager
        if let token = TokenManager.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, httpResponse)
    }
    
    // ⚠️ EQUIVALENTE A TU CAMBIO DE BYPASS SSL: Acepta cualquier certificado (Úsalo solo en Dev)
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                // Acepta explícitamente el Hostname sin validar firmas SSL externas
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}
