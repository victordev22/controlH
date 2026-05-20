//
//  AuthScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct AuthScreen: View {
    // Conexión al enrutador de navegación global
    @Environment(NavigationRouter.self) var router
    
    // Asumimos que tienes tu equivalente al AuthViewModel de Android
    // @StateObject var viewModel = AuthViewModel()
    
    // Estados temporales de simulación (Sustituye a tus collectAsState de Compose)
    @State private var email = ""
    @State private var password = ""
    @State private var nickname = ""
    @State private var isLoginScreen = true
    @State private var passwordVisible = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var isAuthenticated = false

    var body: some View {
        ZStyleContainer {
            VStack(spacing: 16) {
                // Título principal
                Text(isLoginScreen ? "Sign In" : "Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                    .padding(.bottom, 24)
                
                // Campo Email
                TextField("Email", text: $email)
                    .textFieldStyle(OutlinedTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                // Campo Nickname (Condicional)
                if !isLoginScreen {
                    TextField("Nickname", text: $nickname)
                        .textFieldStyle(OutlinedTextFieldStyle())
                }
                
                // Campo Password con alternancia de visibilidad (Trailing Icon nativo)
                HStack {
                    if passwordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    
                    Button(action: { passwordVisible.toggle() }) {
                        Image(systemName: passwordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                
                Spacer().frame(height: 16)
                
                // Botón de Acción o Indicador de Carga
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                        .scaleEffect(1.5)
                        .frame(height: 48)
                } else {
                    Button(action: {
                        ejecutarAuth()
                    }) {
                        Text(isLoginScreen ? "Sign In" : "Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                    }
                }
                
                // Botón de alternancia de pantalla
                Button(action: { isLoginScreen.toggle() }) {
                    Text(isLoginScreen ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.secondary)
                }
                .padding(.top, 16)
                
                // Mensajes de Feedback
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                        .padding(.top, 16)
                }
                
                if let success = successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .font(.callout)
                        .padding(.top, 16)
                }
            }
            .padding(16)
        }
        .navigationTitle("Authentication")
        .navigationBarTitleDisplayMode(.inline)
        // Equivalente al LaunchedEffect(isAuthenticated) de Compose
        .onChange(of: isAuthenticated) { oldValue, newValue in
            if newValue {
                // Navegamos a home y limpiamos el stack de login
                router.popToRoot()
                router.navigate(to: .home)
            }
        }
    }
    
    private func ejecutarAuth() {
        isLoading = true
        // Aquí llamas a tu ApiService y modificas 'isAuthenticated' tras la respuesta exitosa
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            isAuthenticated = true
        }
    }
}

// Helper para emular la estética OutlinedTextField de Material Design 3
struct OutlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
    }
}

// Un contenedor genérico para heredar estructuras visuales limpias
struct ZStyleContainer<Content: View>: View {
    var content: () -> Content
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            content()
        }
    }
}
