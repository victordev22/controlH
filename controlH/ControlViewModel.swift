//
//  ControlViewModel.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation
import Combine

// Estructura idéntica a tu data class PowerUiState de Kotlin
struct PowerUiState {
    var isPoweredOn: Bool = false
    var isConnecting: Bool = false
    var errorMessage: String? = nil
}

@MainActor
class ControlViewModel: ObservableObject {
    
    // @Published emite cambios instantáneos mapeando el comportamiento del StateFlow en Android
    @Published private(set) var uiState = PowerUiState()
    
    private let controlRepository: ControlRepository
    
    init(controlRepository: ControlRepository = ControlRepository()) {
        self.controlRepository = controlRepository
        
        // Equivale al init { fetchInitialPowerState() }
        Task {
            await fetchInitialPowerState()
        }
    }
    
    func togglePower() {
        // viewModelScope.launch se traduce en crear un bloque asíncrono asilado 'Task'
        Task {
            uiState.isConnecting = true
            uiState.errorMessage = nil
            
            // Reemplaza de forma segura la variable 'UserPC' que tenías global
            let userPCName = "UserPC_Placeholder"
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
        let currentUser = MyApp.getSafeCurrentUser()
        
        let result = await controlRepository.listaHoras()
        
        switch result {
        case .success(let horasList):
            // Equivale al predicado .any { it.hora_apagado == nil && it.user == nickname }
            let isPCFound = horasList.contains { hora in
                hora.hora_apagado == nil && hora.user == currentUser?.nickname
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
