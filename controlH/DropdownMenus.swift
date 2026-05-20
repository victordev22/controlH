//
//  DropdownMenus.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

// Estructura de modelo equivalente a tus Data Classes MenuItemData / MenuItemDataList
struct MenuItemData: Identifiable {
    let id = UUID()
    let text: String
    let iconName: String // Nombre del símbolo del sistema de Apple (SF Symbols)
}

// MARK: - PRIMER COMPONENTE: DropdownMenuList
struct DropdownMenuList: View {
    let menuItems = [
        MenuItemData(text: "Encendidas", iconName: "square.and.pencil"),
        MenuItemData(text: "Tarde", iconName: "gearshape"),
        MenuItemData(text: "Menos horas", iconName: "trash")
    ]
    
    @State private var selectedItem: MenuItemData
    
    init() {
        // Inicializamos con el primer elemento por defecto
        _selectedItem = State(initialValue: MenuItemData(text: "Encendidas", iconName: "square.and.pencil"))
    }
    
    var body: some View {
        Menu {
            ForEach(menuItems) { item in
                Button(action: {
                    selectedItem = item
                }) {
                    Label(item.text, systemImage: item.iconName)
                }
            }
        } label: {
            // Estilo visual del botón gatillo
            HStack(spacing: 8) {
                Image(systemName: selectedItem.iconName)
                Text(selectedItem.text)
            }
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }
    }
}

// MARK: - SEGUNDO COMPONENTE: DropdownMenuV
struct DropdownMenuV: View {
    let menuItems = [
        MenuItemData(text: "Edit", iconName: "pencil"),
        MenuItemData(text: "Settings", iconName: "gear"),
        MenuItemData(text: "Delete", iconName: "trash.fill")
    ]
    
    @State private var selectedItem: MenuItemData
    
    init() {
        _selectedItem = State(initialValue: MenuItemData(text: "Edit", iconName: "pencil"))
    }
    
    var body: some View {
        Menu {
            ForEach(menuItems) { item in
                Button(role: item.text == "Delete" ? .destructive : nil, action: {
                    selectedItem = item
                }) {
                    Label(item.text, systemImage: item.iconName)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: selectedItem.iconName)
                Text(selectedItem.text)
            }
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(Color.gray)
            .cornerRadius(8)
        }
    }
}

// MARK: - PREVIEW PARA CANVAS
struct DropdownMenus_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            DropdownMenuList()
            DropdownMenuV()
        }
        .padding()
    }
}
