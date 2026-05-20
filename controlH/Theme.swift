//
//  Theme.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct AppTheme {
    // Colores vinculados automáticamente al catálogo de Assets (Soportan Modo Claro y Oscuro)
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let tertiary = Color("TertiaryColor")

    // Tipografías equivalentes a tu Typography de Compose
    static let bodyLarge: Font = .system(size: 16, weight: .regular, design: .default)
    static let titleLarge: Font = .system(size: 22, weight: .medium, design: .default)
    static let labelSmall: Font = .system(size: 11, weight: .medium, design: .default)
}
