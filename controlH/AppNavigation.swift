//
//  AppNavigation.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//
import SwiftUI

@Observable
class NavigationRouter {
    var path: [AppScreen] = []

    // Funciones rápidas para navegar
    func navigate(to screen: AppScreen) {
        path.append(screen)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }

    func pushAndReplaceRoot(with screen: AppScreen) {
        path = [screen]
    }
}
