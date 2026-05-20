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
                // Splash puro: sin NavigationStack, solo dura 3 segundos
                BoxContainerView {
                    Text("Welcome")
                        .font(.system(size: 30, weight: .bold))
                }
                .task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    isLaunching = false
                }
            } else {
                // El estado de autenticación decide la raíz: no hay riesgo de volver a Splash
                NavigationStack(path: $router.path) {
                    Group {
                        if authViewModel.isAuthenticated {
                            HomeScreen()
                        } else {
                            AuthScreen()
                        }
                    }
                    .navigationDestination(for: AppScreen.self) { screen in
                        switch screen {
                        case .list:           ListScreen()
                        case .listU:          ListUser()
                        case .detail(let id): DetailScreen(id: id)
                        default:              EmptyView()
                        }
                    }
                }
                // Al cerrar sesión limpia el path antes de mostrar AuthScreen
                .onChange(of: authViewModel.isAuthenticated) { _, isAuth in
                    if !isAuth { router.popToRoot() }
                }
            }
        }
        .environment(router)
        .environment(authViewModel)
    }
}
