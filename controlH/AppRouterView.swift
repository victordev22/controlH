//
//  AppRouterView.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct AppRouterView: View {
    @State private var router = NavigationRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            // Destino inicial (Sustituye a startDestination)
            Group {
                // Aquí llamaremos a tu SplashScreen nativa. Por ahora dejamos un marcador de posición.
                Text("Splash Screen (Cargando...)")
                    .font(AppTheme.titleLarge)
                    .foregroundColor(AppTheme.primary)
                    .onAppear {
                        // Simular retraso del splash y mandar a Login
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            router.navigate(to: .login)
                        }
                    }
            }
            // Aquí es donde el NavHost mapea cada pantalla
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {
                case .splash:
                    Text("Splash View")
                case .login:
                    Text("Login View (Pulsar para ir a Home)")
                        .onTapGesture { router.navigate(to: .home) }
                case .home:
                    Text("Home View (Pulsar para ir a Detalle)")
                        .onTapGesture { router.navigate(to: .detail(id: 42)) }
                case .list:
                    Text("List View")
                case .listU:
                    Text("List User View")
                case .auth:
                    Text("Auth View")
                case .detail(let id):
                    // Pasamos el ID directamente como un parámetro nativo de inicialización
                    Text("Detail View de la PC con ID: \(id)")
                }
            }
        }
        // Inyectamos el router en toda la app para poder navegar desde cualquier pantalla secundaria
        .environment(router)
    }
}
