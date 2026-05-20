//
//  AppRouterView.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct AppRouterView: View {
    @State private var router        = NavigationRouter()
    @State private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            SplashScreen()
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen {
                    case .splash:
                        SplashScreen()
                    case .login, .auth:
                        AuthScreen()
                    case .home:
                        HomeScreen()
                    case .list:
                        ListScreen()
                    case .listU:
                        ListUser()
                    case .detail(let id):
                        DetailScreen(id: id)
                    }
                }
        }
        .environment(router)
        .environment(authViewModel)
    }
}
