//
//  ControlViewModel.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

// Estructura idéntica a tu data class PowerUiState de Kotlin
struct PowerUiState {
    var isPoweredOn: Bool = false
    var isConnecting: Bool = false
    var errorMessage: String? = nil
}

@MainActor
@Observable
class ControlViewModel {

    private(set) var uiState = PowerUiState()
    
    private let controlRepository: ControlRepository
    
    init(controlRepository: ControlRepository = ControlRepository()) {
        self.controlRepository = controlRepository
        
        // Equivale al init { fetchInitialPowerState() }
        Task {
            await fetchInitialPowerState()
        }
    }
    
    func togglePower() {
        Task {
            uiState.isConnecting = true
            uiState.errorMessage = nil

            let userPCName = AppState.shared.currentUser?.nickname ?? ""
            let command = uiState.isPoweredOn ? "sh \(userPCName)_off.sh" : "sh \(userPCName).sh"
            
            let result = await controlRepository.connectToSsh(command: command)
            
            switch result {
            case .success:
                uiState.isPoweredOn.toggle()
                uiState.isConnecting = false
            case .failure(let error):
                uiState.isConnecting = false
                uiState.errorMessage = "Failed to toggle power: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchInitialPowerState() async {
        uiState.isConnecting = true
        let currentUser: User?
        if let cached = AppState.shared.currentUser {
            currentUser = cached
        } else {
            currentUser = try? await ApiService.shared.getCurrentUser()
            if let user = currentUser { AppState.shared.updateCurrentUser(user) }
        }

        let result = await controlRepository.listaHoras()
        
        switch result {
        case .success(let horasList):
            // Equivale al predicado .any { it.hora_apagado == nil && it.user == nickname }
            let isPCFound = horasList.contains { hora in
                hora.horaApagado == nil && hora.user == currentUser?.nickname
            }
            
            print("ControlViewModel: PC Status Check: isPCFound=\(isPCFound) for user=\(currentUser?.nickname ?? "")")
            uiState.isPoweredOn = isPCFound
            uiState.isConnecting = false
            
        case .failure(let error):
            uiState.isConnecting = false
            uiState.errorMessage = "Failed to fetch status: \(error.localizedDescription)"
        }
    }
}
