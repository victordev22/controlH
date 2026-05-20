//
//  AppRouterView.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct AppRouterView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var router        = NavigationRouter()
    @State private var isLaunching   = true

    var body: some View {
        Group {
            if isLaunching {
                // Splash sin NavigationStack propio
                BoxContainerView {
                    Text("Welcome")
                        .font(.system(size: 30, weight: .bold))
                }
                .task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    isLaunching = false
                }
            } else if authViewModel.isAuthenticated {
                // HomeScreen gestiona su propia navegación via TabView + NavigationStack por tab.
                // NO se envuelve aquí en otro NavigationStack para evitar nesting de barras.
                HomeScreen()
            } else {
                // Solo la pantalla de auth necesita su propio NavigationStack
                NavigationStack {
                    AuthScreen()
                }
            }
        }
        .environment(router)
        .environment(authViewModel)
        .onChange(of: authViewModel.isAuthenticated) { _, isAuth in
            if !isAuth { router.popToRoot() }
        }
    }
}
