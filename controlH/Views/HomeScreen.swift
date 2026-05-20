//
//  HomeScreen.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(NavigationRouter.self) var router
    @Environment(AuthViewModel.self)   var authViewModel

    @State private var controlViewModel = ControlViewModel()
    @State private var horasList: [Horas] = []
    @State private var selectedTab = 0

    private var nickname: String {
        authViewModel.userData?.nickname
            ?? authViewModel.currentUser?.nickname
            ?? "Usuario"
    }

    private var isAdmin: Bool {
        (authViewModel.userData?.roles ?? authViewModel.currentUser?.roles ?? [])
            .contains { $0.erole == "ROLE_ADMIN" }
    }

    private var userHorasToday: [Horas] {
        horasList.filter { h in
            h.user == nickname &&
            (h.horaEncendido.map { Calendar.current.isDateInToday($0) } == true)
        }
    }

    private var elapsedDailyMinutes: Int {
        userHorasToday.reduce(0) { sum, h in
            guard let start = h.horaEncendido else { return sum }
            let end = h.horaApagado ?? Date()
            return sum + max(0, Int(end.timeIntervalSince(start) / 60))
        }
    }

    private var totalWeeklyMinutes: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return horasList.filter { h in
            h.user == nickname &&
            (h.horaEncendido.map { $0 >= weekAgo } == true)
        }.reduce(0) { sum, h in
            guard let start = h.horaEncendido else { return sum }
            let end = h.horaApagado ?? Date()
            return sum + max(0, Int(end.timeIntervalSince(start) / 60))
        }
    }

    private var usageTimeDisplay: String {
        let total = elapsedDailyMinutes * 60
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // --- PESTAÑA 1: HOME PANEL ---
            NavigationStack {
                Group {
                    if isAdmin {
                        AdminBodyContent(
                            elapsedDailyMinutes: elapsedDailyMinutes,
                            totalWeeklyMinutes: totalWeeklyMinutes,
                            controlViewModel: controlViewModel
                        )
                    } else {
                        HomeBodyContent(
                            userPC: String(nickname.suffix(2)).uppercased(),
                            usageTimeDisplay: usageTimeDisplay,
                            elapsedDailyMinutes: elapsedDailyMinutes,
                            totalWeeklyMinutes: totalWeeklyMinutes,
                            controlViewModel: controlViewModel
                        )
                    }
                }
                .navigationTitle(nickname)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { authViewModel.logout() }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            // --- PESTAÑA 2: LISTADO DE HORAS ---
            ListScreen()
            .tabItem { Label("Horas", systemImage: "list.bullet") }
            .tag(1)

            // --- PESTAÑA 3: ADMIN (SOLO SI ES ADMIN) ---
            if isAdmin {
                ListUser()
                .tabItem { Label("Usuarios", systemImage: "person.fill") }
                .tag(2)
            }
        }
        .accentColor(AppTheme.primary)
        .task { await loadHoras() }
    }

    private func loadHoras() async {
        do {
            horasList = try await ApiService.shared.getHoras()
        } catch {
            print("HomeScreen: error cargando horas - \(error.localizedDescription)")
        }
    }
}

// MARK: - CUERPO DE USUARIO
struct HomeBodyContent: View {
    let userPC: String
    let usageTimeDisplay: String
    let elapsedDailyMinutes: Int
    let totalWeeklyMinutes: Int
    let controlViewModel: ControlViewModel

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

            HStack(spacing: 24) {
                UsageLimitProgress(usedMinutes: elapsedDailyMinutes, maxMinutes: Constants.dailyMaxMinutes, label: "Diario", canvasSize: 140)
                UsageLimitProgress(usedMinutes: totalWeeklyMinutes, maxMinutes: Constants.weeklyMaxMinutes, label: "Semanal", canvasSize: 140)
            }

            Spacer()

            PowerOnOf(viewModel: controlViewModel)
                .padding(.bottom, 32)
        }
        .padding()
    }
}

// MARK: - CUERPO DE ADMINISTRADOR
struct AdminBodyContent: View {
    let elapsedDailyMinutes: Int
    let totalWeeklyMinutes: Int
    let controlViewModel: ControlViewModel

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
                PowerOnOf(viewModel: controlViewModel)

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

// MARK: - PREVIEW
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environment(NavigationRouter())
            .environment(AuthViewModel())
    }
}
