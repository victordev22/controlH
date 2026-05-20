//
//  HomeScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(NavigationRouter.self) var router
    // @StateObject var homeViewModel = HomeViewModel() // Instancia de tu lógica
    // @EnvironmentObject var authViewModel: AuthViewModel
    
    // Estados simulados para que compile de inmediato (Equivalente a collectAsState)
    @State private var nickname: String = "UserAdmin_PC"
    @State private var isAdmin: Bool = true
    @State private var usageTimeDisplay: String = "02:15:40"
    @State private var elapsedDailyMinutes: Int = 135
    @State private var totalWeeklyMinutes: Int = 840
    
    // Pestaña activa por defecto en el Bottom Bar (0 = Home, 1 = Horas, 2 = Usuarios)
    @State private var selectedTab = 0
    
    var body: some View {
        // En iOS usamos TabView para emular el NavigationBar + Scaffold de Compose
        TabView(selection: $selectedTab) {
            
            // --- PESTAÑA 1: HOME PANEL ---
            NavigationStack {
                Group {
                    if isAdmin {
                        AdminBodyContent(
                            elapsedDailyMinutes: elapsedDailyMinutes,
                            totalWeeklyMinutes: totalWeeklyMinutes
                        )
                    } else {
                        HomeBodyContent(
                            userPC: String(nickname.suffix(2)).uppercased(),
                            usageTimeDisplay: usageTimeDisplay,
                            elapsedDailyMinutes: elapsedDailyMinutes,
                            totalWeeklyMinutes: totalWeeklyMinutes
                        )
                    }
                }
                .navigationTitle(nickname)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Botón de salir ubicado arriba a la derecha en la barra nativa (TopAppBar)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // authViewModel.logout()
                            router.popToRoot()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // --- PESTAÑA 2: LISTADO DE HORAS ---
            ListScreen()
            .tabItem {
                Label("Horas", systemImage: "list.bullet")
            }
            .tag(1)

            // --- PESTAÑA 3: ADMIN (SOLO SI ES ADMIN) ---
            if isAdmin {
                ListUser()
                .tabItem {
                    Label("Usuarios", systemImage: "person.fill")
                }
                .tag(2)
            }
        }
        // Aplica el color del tema a la pestaña seleccionada
        .accentColor(AppTheme.primary)
    }
}

// MARK: - CUERPO DE USUARIO (HomeBodyContent)
struct HomeBodyContent: View {
    let userPC: String
    let usageTimeDisplay: String
    let elapsedDailyMinutes: Int
    let totalWeeklyMinutes: Int
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Control de PC Personal")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Tu PC asignada es PC\(userPC) | Hoy: \(usageTimeDisplay)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 32)
            
            // Fila con los dos arcos gráficos (UsageLimitProgress)
            HStack(spacing: 24) {
                UsageLimitProgress(usedMinutes: elapsedDailyMinutes, maxMinutes: Constants.dailyMaxMinutes, label: "Diario", canvasSize: 140)
                UsageLimitProgress(usedMinutes: totalWeeklyMinutes, maxMinutes: Constants.weeklyMaxMinutes, label: "Semanal", canvasSize: 140)
            }
            
            Spacer()
            
            // Simulación del botón/control de encendido
            PowerOnOfPlaceholder()
                .padding(.bottom, 32)
        }
        .padding()
    }
}

// MARK: - CUERPO DE ADMINISTRADOR (AdminBodyContent)
struct AdminBodyContent: View {
    let elapsedDailyMinutes: Int
    let totalWeeklyMinutes: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Panel de Administrador")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 24)
            
            HStack(spacing: 24) {
                UsageLimitProgress(usedMinutes: elapsedDailyMinutes, maxMinutes: Constants.dailyMaxMinutes, label: "Diario", canvasSize: 140)
                UsageLimitProgress(usedMinutes: totalWeeklyMinutes, maxMinutes: Constants.weeklyMaxMinutes, label: "Semanal", canvasSize: 140)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                PowerOnOfPlaceholder()
                
                // Botón de prueba para disparar notificaciones en local (Sustituye WorkManager)
                Button(action: {
                    NotificationManager.shared.requestPermissions()
                    print("Lanzando disparo de prueba de notificación local...")
                }) {
                    Text("Probar Notificación Ahora")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
}

// MARK: - COMPONENTES MOCK DE SOPORTE
struct PowerOnOfPlaceholder: View {
    @State private var isPcOn = false
    
    var body: some View {
        Toggle(isOn: $isPcOn) {
            Text(isPcOn ? "Apagar Equipo Asignado" : "Encender Equipo Asignado")
                .font(.headline)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - PREVIEW
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environment(NavigationRouter())
    }
}
