//
//  SplashScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var router: NavigationRouter
    // @EnvironmentObject var authViewModel: AuthViewModel

    // Estado de sesión simulado para pruebas de compilación de interfaz
    @State private var isAuthenticated: Bool = false

    var body: some View {
        BoxContainerView {
            Text("Welcome")
                .font(.system(size: 30, weight: .bold))
        }
        .task {
            // Agregamos el retraso idéntico al 'delay(3000)' de Kotlin Coroutines
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            if isAuthenticated {
                // Navega al Home limpiando el historial para evitar volver atrás
                router.pushAndReplaceRoot(with: .home)
            } else {
                router.pushAndReplaceRoot(with: .login)
            }
        }
    }
}

// Contenedor utilitario reutilizable alineado al centro de la pantalla
struct BoxContainerView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            content
        }
    }
}

// MARK: - PREVIEW
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .environmentObject(NavigationRouter())
    }
}
