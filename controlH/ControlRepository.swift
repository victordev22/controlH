//
//  ControlRepository.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case emptyBody
    case apiError(statusCode: Int)
}

class ControlRepository {
    
    // Simula tus llamadas de endpoint tipadas (Equivalente a ControlService/ApiService de Retrofit)
    func listaHoras() async -> Result<[Horas], Error> {
        guard let url = URL(string: Constants.baseURL + Constants.pathWines) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Pasamos la peticiÃ³n por nuestro inyector de tokens antes de enviarla
        request = AuthInterceptor.shared.adapt(request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.invalidResponse)
            }
            
            if httpResponse.statusCode == 200 {
                let decodedHoras = try JSONDecoder().decode([Horas].self, from: data)
                return .success(decodedHoras)
            } else {
                return .failure(NetworkError.apiError(statusCode: httpResponse.statusCode))
            }
        } catch {
            return .failure(error)
        }
    }
    
    func connectToSsh(command: String) async -> Result<Bool, Error> {
        // Codifica el comando para sanitizar caracteres en URL query strings
        guard let encodedCommand = command.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: Constants.baseSsh + encodedCommand) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request = AuthInterceptor.shared.adapt(request)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.invalidResponse)
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                print("ControlRepository: Command sent successfully: \(command)")
                return .success(true)
            } else {
                return .failure(NetworkError.apiError(statusCode: httpResponse.statusCode))
            }
        } catch {
            print("ControlRepository: Exception during SSH: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
