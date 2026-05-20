//
//  EditUserDialog.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct EditUserView: View {
    // Al cerrar la hoja de ediciÃ³n en iOS
    @Environment(\.dismiss) var dismiss
    
    let user: UserFull
    var onConfirm: (UserFull, Int) -> Void
    
    // Estados inicializados con valores seguros de forma desempaquetada
    @State private var nickname: String
    @State private var email: String
    @State private var onTime: String
    @State private var offTime: String
    @State private var selectedRoleId: Int
    
    init(user: UserFull, onConfirm: @escaping (UserFull, Int) -> Void) {
        self.user = user
        self.onConfirm = onConfirm
        _nickname = State(initialValue: user.nickname)
        _email    = State(initialValue: user.email)
        _onTime   = State(initialValue: user.onControl)
        _offTime  = State(initialValue: user.ofControl)
        
        let isAdmin = user.roles.contains { $0.erole == "ROLE_ADMIN" }
        _selectedRoleId = State(initialValue: isAdmin ? 2 : 1)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Datos Personales")) {
                    TextField("Nickname", text: $nickname)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Rol de Usuario")) {
                    Picker("Seleccionar Rol", selection: $selectedRoleId) {
                        Text("USUARIO").tag(1)
                        Text("ADMINISTRADOR").tag(2)
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Control de Tiempos")) {
                    TextField("Encendido (HH:mm:ss)", text: $onTime)
                    TextField("Apagado (HH:mm:ss)", text: $offTime)
                }
            }
            .navigationTitle("Editar Usuario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let updatedUser = UserFull(
                            id: user.id,
                            nickname: nickname,
                            email: email,
                            password: user.password,
                            onControl: onTime,
                            ofControl: offTime,
                            roles: user.roles
                        )
                        onConfirm(updatedUser, selectedRoleId)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
