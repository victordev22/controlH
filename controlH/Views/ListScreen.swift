//
//  ListScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

// Equivalente al Enum de Kotlin
enum FilterType: String, CaseIterable {
    case all = "Ver todos"
    case poweredOn = "PCs Encendidas"
    case cameLate = "Entraron Tarde"
    case menosTime = "Menos Horas"
    case byUser = "Filtrar por Usuario"
}

struct ListScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    // Estados de datos (Equivalente a mutableStateListOf y mutableStateOf)
    @State private var horasList: [Horas] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var filterType: FilterType = .all
    @State private var selectedUser: String? = nil
    @State private var uniqueUsers: [String] = []

    // Filtrado reactivo (Equivalente al remember(horasList, filterType...) con derived state)
    var filteredHoras: [Horas] {
        let baseList = selectedUser != nil ? horasList.filter { $0.user == selectedUser } : horasList
        
        switch filterType {
        case .all, .byUser:
            return baseList
        case .poweredOn:
            // Filtra los registros que no tienen hora de apagado
            return baseList.filter { $0.horaApagado == nil }
        case .cameLate:
            return baseList.filter { hora in
                guard let encendido = hora.horaEncendido else { return false }
                let calendar = Calendar.current
                
                // Definir hora límite a las 09:00 del mismo día
                var componentesLimite = calendar.dateComponents([.year, .month, .day], from: encendido)
                componentesLimite.hour = 9
                componentesLimite.minute = 0
                componentesLimite.second = 0
                
                guard let limite9AM = calendar.date(from: componentesLimite) else { return false }
                return encendido > limite9AM
            }
        case .menosTime:
            return horasList.filter { hora in
                guard let encendido = hora.horaEncendido, let apagado = hora.horaApagado else { return false }
                
                var diff = apagado.timeIntervalSince(encendido)
                if apagado < encendido {
                    // Si el apagado es previo, asumimos cambio de día (+24 horas)
                    diff += 24 * 60 * 60
                }
                
                // Menos de 8 horas (en segundos)
                return diff < (8 * 60 * 60)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView("Cargando datos...")
                    Spacer()
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Reintentar") {
                            Task { await fetchHorasData() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else if filteredHoras.isEmpty {
                    Spacer()
                    Text("No hay registros de horas.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    // LazyColumn equivalente en SwiftUI utilizando List optimizada
                    List(filteredHoras) { hora in
                        CardItemHorasView(hora: hora)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Listado de Horas")
            .navigationBarTitleDisplayMode(.inline)
            // Configuración de la barra superior (TopAppBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Atrás")
                        }
                    }
                }
                
                // Menú de filtrado desplegable (DropdownFilterMenu)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Ver todos") {
                            filterType = .all
                            selectedUser = nil
                        }
                        Button("PCs Encendidas") {
                            filterType = .poweredOn
                            selectedUser = nil
                        }
                        Button("Entraron Tarde") {
                            filterType = .cameLate
                            selectedUser = nil
                        }
                        Button("Menos Horas") {
                            filterType = .menosTime
                            selectedUser = nil
                        }
                        
                        Divider()
                        
                        Text("--- Filtrar por Usuario ---")
                        
                        ForEach(uniqueUsers, id: \.self) { user in
                            Button(action: {
                                filterType = .byUser
                                selectedUser = user
                            }) {
                                HStack {
                                    Text(user)
                                    if user == selectedUser {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                    }
                }
            }
            // Disparador de carga asíncrona segura al entrar en escena
            .task {
                await fetchHorasData()
            }
        }
    }

    private func fetchHorasData() async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await ApiService.shared.getHoras()
            horasList   = data
            uniqueUsers = Array(Set(data.map { $0.user })).sorted()
            isLoading   = false
        } catch {
            errorMessage = "Error de red: \(error.localizedDescription)"
            isLoading    = false
        }
    }
}

// MARK: - COMPONENTE CARD (CardItemComposable)
struct CardItemHorasView: View {
    let hora: Horas
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(hora.user)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primary)

            Group {
                Text("Encendido: ") + Text(hora.horaEncendido?.formatted() ?? "N/A").foregroundColor(.primary)
                Text("Apagado: ") + Text(hora.horaApagado?.formatted() ?? "En curso...").foregroundColor(.primary)
                Text("Inactividad: ") + Text("\(hora.minutosInactivo) min").foregroundColor(.primary)
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
