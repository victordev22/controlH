//
//  AuthScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct AuthScreen: View {
    @Environment(NavigationRouter.self) var router
    @Environment(AuthViewModel.self)   var authViewModel

    @State private var passwordVisible = false

    var body: some View {
        @Bindable var vm = authViewModel

        ZStyleContainer {
            VStack(spacing: 16) {
                Text(vm.isLoginScreen ? "Sign In" : "Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primary)
                    .padding(.bottom, 24)

                TextField("Email", text: $vm.email)
                    .textFieldStyle(OutlinedTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                if !vm.isLoginScreen {
                    TextField("Nickname", text: $vm.nickname)
                        .textFieldStyle(OutlinedTextFieldStyle())
                }

                HStack {
                    if passwordVisible {
                        TextField("Password", text: $vm.password)
                    } else {
                        SecureField("Password", text: $vm.password)
                    }
                    Button(action: { passwordVisible.toggle() }) {
                        Image(systemName: passwordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))

                Spacer().frame(height: 16)

                if vm.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                        .scaleEffect(1.5)
                        .frame(height: 48)
                } else {
                    Button(action: {
                        Task {
                            if authViewModel.isLoginScreen {
                                await authViewModel.signIn()
                            } else {
                                await authViewModel.signUp()
                            }
                        }
                    }) {
                        Text(vm.isLoginScreen ? "Sign In" : "Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.primary)
                            .cornerRadius(8)
                    }
                }

                Button(action: { authViewModel.toggleAuthScreen() }) {
                    Text(vm.isLoginScreen
                         ? "Don't have an account? Sign Up"
                         : "Already have an account? Sign In")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.secondary)
                }
                .padding(.top, 16)

                if let error = vm.errorMessage {
                    Text(error).foregroundColor(.red).font(.callout).padding(.top, 8)
                }
                if let success = vm.successMessage {
                    Text(success).foregroundColor(.green).font(.callout).padding(.top, 8)
                }
            }
            .padding(16)
        }
        .navigationTitle("Authentication")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: authViewModel.isAuthenticated) { _, newValue in
            if newValue {
                router.pushAndReplaceRoot(with: .home)
            }
        }
    }
}

// MARK: - Helpers de estilo

struct OutlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
    }
}

struct ZStyleContainer<Content: View>: View {
    var content: () -> Content
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            content()
        }
    }
}
