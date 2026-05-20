//
//  AuthViewModel.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // Campos del Formulario reactivos
    @Published var email = ""
    @Published var password = ""
    @Published var nickname = ""
    
    // Estados Globales
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var isLoginScreen = true
    @Published var isAuthenticated = false
    @Published var currentUser: User? = nil
    @Published var userData: UserFull? = nil
    
    init() {
        self.isAuthenticated = TokenManager.getToken() != nil
        print("AuthViewModel initialized. isAuthenticated: \(isAuthenticated)")
        
        if isAuthenticated {
            Task { await fetchCurrentUser() }
        }
    }
    
    func toggleAuthScreen() {
        isLoginScreen.toggle()
        errorMessage = nil
        successMessage = nil
        email = ""
        password = ""
        nickname = ""
    }
    
    func signIn() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            // Lógica estructurada de llamada a API usando async/await (Mapeo de RetrofitClient)
            do {
                // Aquí irían tus llamadas reales de red, simulamos éxito para flujo gráfico:
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                let simulatedToken = "JWT_TOKEN_SAMPLE"
                TokenManager.saveToken(token: simulatedToken)
                self.isAuthenticated = true
                self.successMessage = "\(email) signed in successfully!"
                
                await fetchCurrentUser()
            } catch {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func signUp() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            // Lógica asíncrona de registro...
            isLoading = false
        }
    }
    
    func fetchCurrentUser() async {
        isLoading = true
        // Simulando llamada del perfil
        do {
            // Al recuperar el usuario, enlazamos el APNS/FCM Token nativo de iOS como tu código de NovuManager:
            /*
            Messaging.messaging().token { token, error in
                if let token = token {
                     NovuManager.vincularDispositivo(email: self.email, token: token)
                }
            }
            */
            print("Successfully fetched user profile details")
        }
        isLoading = false
    }
    
    func logout() {
        TokenManager.clearToken()
        isAuthenticated = false
        successMessage = "You have been logged out."
        currentUser = nil
        userData = nil
        email = ""
        password = ""
        nickname = ""
        isLoginScreen = true
    }
}
