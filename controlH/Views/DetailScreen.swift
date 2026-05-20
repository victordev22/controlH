//
//  DetailScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct DetailScreen: View {
    let id: Int
    @Environment(NavigationRouter.self) var router
    
    @State private var horaData: Horas? = nil
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Información Principal
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Usuario: \(horaData?.user ?? "N/A")")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("ID Registro: \(id)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Tarjetas de Métricas (Dashboard Cards)
                        HStack(spacing: 16) {
                            let esActivo = horaData?.horaApagado == nil
                            DashboardCard(
                                label: "Estado",
                                value: esActivo ? "Activo" : "Finalizado",
                                color: esActivo ? Color.green : Color.gray
                            )
                            
                            DashboardCard(
                                label: "Inactividad",
                                value: "\(horaData?.minutosInactivo ?? 0) min",
                                color: Color.orange
                            )
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Sección de Aplicaciones
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aplicaciones en sesión:")
                                .font(.headline)
                            
                            if let apps = horaData?.listaApps, !apps.isEmpty {
                                let appsList = apps.components(separatedBy: ",")
                                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty }
                                
                                // El equivalente nativo a FlowRow para envolver elementos automáticamente
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                    ForEach(appsList, id: \.self) { appName in
                                        AppChip(name: appName)
                                    }
                                }
                            } else {
                                Text("No se registraron aplicaciones.")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Dashboard de Usuario")
        .navigationBarTitleDisplayMode(.inline)
        // Hacemos el fetch de datos asíncrono asilado en lugar de usar librerías metidas en la vista
        .task {
            do {
                // Llamamos a tu servicio centralizado de red asíncrono
                let data = try await ApiService.shared.getHoraById(id: id)
                self.horaData = data
                self.isLoading = false
            } catch {
                print("Error cargando detalles de horas: \(error)")
                self.isLoading = false
            }
        }
    }
}

// Subcomponente: Tarjeta Dashboard
struct DashboardCard: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(width: 150, height: 100)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// Subcomponente: Chip de Aplicaciones
struct AppChip: View {
    let name: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            Text(name.replacingOccurrences(of: ".exe", with: ""))
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}
