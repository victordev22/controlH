//
//  AppScreens.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation

// Definimos nuestras pantallas. El caso 'detail' recibe su ID directamente
enum AppScreen: Hashable {
    case splash
    case login
    case home
    case list
    case listU
    case auth
    case detail(id: Int) // Reemplaza a "detail_screen/{id}"
}
