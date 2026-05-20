//
//  SplashScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct SplashScreen: View {
    @Environment(NavigationRouter.self) var router
    // @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        BoxContainerView {
            Text("Welcome")
                .font(.system(size: 30, weight: .bold))
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            // Navega según si ya existe un token JWT guardado en Keychain
            if TokenManager.getToken() != nil {
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
            .environment(NavigationRouter())
    }
}
