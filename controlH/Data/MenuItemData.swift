//
//  MenuItemData.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import SwiftUI

struct MenuItemData: Identifiable {
    let id = UUID() // Ayuda a SwiftUI a identificar el elemento en un menú/lista
    let text: String
    let iconName: String // Ejemplo: "house.fill", "person.circle", etc.
}
