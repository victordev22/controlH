//
//  ListUser.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct ListUser: View {
    @Environment(\.dismiss) private var dismiss
    
    // Estados compartidos de gestión de usuarios
    @State private var userList: [UserFull] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    // Estados de interacción para diálogos modales
    @State private var showEditDialog = false
    @State private var selectedUser: UserFull? = nil
    
    @State private var showDeleteDialog = false
    @State private var userToDelete: UserFull? = nil

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundColor(.red)
                        Button("Reintentar") { refreshData() }
                    }
                    Spacer()
                } else {
                    List(userList) { user in
                        CardItemUserView(
                            user: user,
                            onEdit: {
                                selectedUser = user
                                showEditDialog = true
                            },
                            onDelete: {
                                userToDelete = user
                                showDeleteDialog = true
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Gestión de Usuarios")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Atrás") { dismiss() }
                }
            }
            .onAppear {
                refreshData()
            }
            // --- DIÁLOGO DE CONFIRMACIÓN DE ELIMINACIÓN ---
            .alert("¿Eliminar usuario?", isPresented: $showDeleteDialog, presenting: userToDelete) { user in
                Button("Eliminar", role: .destructive) {
                    deleteUserAction(id: user.id)
                }
                Button("Cancelar", role: .cancel) { }
            } message: { user in
                Text("¿Estás seguro de que quieres eliminar a \(user.nickname)? Esta acción no se puede deshacer.")
            }
            // --- MODAL DE EDICIÓN DE DETALLES DEL USUARIO ---
            .sheet(item: $selectedUser) { user in
                EditUserDialogView(user: user) { updatedUser, roleId in
                    updateUserAction(user: updatedUser, roleId: roleId)
                }
            }
        }
    }

    private func refreshData() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                userList  = try await ApiService.shared.getAllUsersFull()
                isLoading = false
            } catch {
                errorMessage = "Error al cargar usuarios: \(error.localizedDescription)"
                isLoading    = false
            }
        }
    }

    private func deleteUserAction(id: Int) {
        Task {
            do {
                try await ApiService.shared.deleteUser(id: Int64(id))
                userList.removeAll { $0.id == id }
            } catch {
                errorMessage = "Error al eliminar: \(error.localizedDescription)"
            }
        }
    }

    private func updateUserAction(user: UserFull, roleId: Int) {
        Task {
            do {
                let roleErole = roleId == 1 ? "ROLE_ADMIN" : "ROLE_USER"
                _ = try await ApiService.shared.updateUserRole(
                    email: user.email,
                    roleRequest: RoleUpdateRequest(newRoleId: roleId)
                )
                if let index = userList.firstIndex(where: { $0.id == user.id }) {
                    var updated = user
                    updated.roles = [Role(erole: roleErole)]
                    userList[index] = updated
                }
            } catch {
                errorMessage = "Error al actualizar: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - FILA COMPONENTE DE USUARIOS (CardItemComposable)
struct CardItemUserView: View {
    let user: UserFull
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.nickname)
                    .font(.headline)
                    .foregroundColor(AppTheme.primary)
                Text("Email: \(user.email)")
                    .font(.subheadline)
                Text("Rol: \(user.roles.contains { $0.erole == "ROLE_ADMIN" } ? "ADMIN" : "USER")")
                    .font(.caption)
                    .bold()
                Text("ON: \(user.onControl) | OFF: \(user.ofControl)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - DIÁLOGO/FORMULARIO DE EDICIÓN MODAL (EditUserDialog)
struct EditUserDialogView: View {
    @Environment(\.dismiss) private var dismiss
    let user: UserFull
    var onConfirm: (UserFull, Int) -> Void
    
    // Estados internos enlazados para las entradas del formulario
    @State private var nickname: String = ""
    @State private var email: String = ""
    @State private var selectedRoleId = 2 // 1: Admin, 2: User
    
    init(user: UserFull, onConfirm: @escaping (UserFull, Int) -> Void) {
        self.user = user
        self.onConfirm = onConfirm
        // Inicializar estados con la data actual del modelo inyectado
        _nickname = State(initialValue: user.nickname)
        _email = State(initialValue: user.email)
        let isAdmin = user.roles.contains { $0.erole == "ROLE_ADMIN" }
        _selectedRoleId = State(initialValue: isAdmin ? 1 : 2)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información General")) {
                    TextField("Nickname", text: $nickname)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Asignación de Roles")) {
                    Picker("Rol de Acceso", selection: $selectedRoleId) {
                        Text("Administrador").tag(1)
                        Text("Usuario Estándar").tag(2)
                    }
                    .pickerStyle(.segmented)
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
                        var updatedUser = user
                        updatedUser.nickname = nickname
                        updatedUser.email = email
                        onConfirm(updatedUser, selectedRoleId)
                        dismiss()
                    }
                }
            }
        }
    }
}
