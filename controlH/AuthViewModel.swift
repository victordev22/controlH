//
//  AuthViewModel.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

@MainActor
@Observable
class AuthViewModel {

    var email        = ""
    var password     = ""
    var nickname     = ""
    var isLoading    = false
    var errorMessage:   String? = nil
    var successMessage: String? = nil
    var isLoginScreen   = true
    var isAuthenticated = false
    var currentUser:  User?     = nil
    var userData:     UserFull? = nil

    init() {
        isAuthenticated = TokenManager.getToken() != nil
        if isAuthenticated {
            Task { await fetchCurrentUser() }
        }
    }

    func toggleAuthScreen() {
        isLoginScreen.toggle()
        errorMessage   = nil
        successMessage = nil
        email    = ""
        password = ""
        nickname = ""
    }

    func signIn() async {
        isLoading    = true
        errorMessage = nil

        do {
            let jwtResponse = try await ApiService.shared.login(
                requestData: LoginRequest(email: email, password: password)
            )
            TokenManager.saveToken(token: jwtResponse.token)
            isAuthenticated = true
            successMessage  = "\(email) sesión iniciada correctamente"
            await fetchCurrentUser()
        } catch {
            errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func signUp() async {
        isLoading    = true
        errorMessage = nil

        do {
            let signupRequest = SignupRequest(nickname: nickname, email: email, password: password)
            _ = try await ApiService.shared.signup(requestData: signupRequest)
            successMessage = "Cuenta creada. Por favor inicia sesión."
            isLoginScreen  = true
        } catch {
            errorMessage = "Error al registrarse: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func fetchCurrentUser() async {
        do {
            let user = try await ApiService.shared.getCurrentUser()
            currentUser = user
            AppState.shared.updateCurrentUser(user)
            userData = try await ApiService.shared.getRawCurrentUserJson()
        } catch {
            print("AuthViewModel: error al cargar usuario - \(error.localizedDescription)")
        }
    }

    func logout() {
        TokenManager.clearToken()
        ApiService.shared.jwtToken = nil
        isAuthenticated = false
        currentUser     = nil
        userData        = nil
        email    = ""
        password = ""
        nickname = ""
        isLoginScreen = true
        AppState.shared.currentUser = nil
    }
}
