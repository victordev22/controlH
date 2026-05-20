//
//  LoginView.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(NavigationRouter.self) var router

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("El login")
                    .font(.title2)

                Button(action: {
                    // Acción del botón: Navega al Home enrutado de forma segura
                    router.navigate(to: .home)
                }) {
                    Text("Navega")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(AppTheme.primary)
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - PREVIEW
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environment(NavigationRouter())
    }
}
