//
//  NotificationWorker.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation
import BackgroundTasks
import UserNotifications

class NotificationWorker {
    static let taskIdentifier = "com.controlh.dailycheck"
    
    static func registerTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            self.handleTaskExecution(processingTask)
        }
    }
    
    private static func handleTaskExecution(_ task: BGProcessingTask) {
        // Creamos la reprogramación futura de manera preventiva
        scheduleNextCheck(delayInSeconds: 24 * 3600) // Próxima ventana (mañana)
        
        Task {
            do {
                // Ejecutamos tus validaciones de servidor asíncronas
                let (userData, _) = try await RetrofitClient.shared.request(for: Constants.baseAuth + "auth/me")
                // Mapeas tus decodificaciones y lógica de negocio para ver si la PC sigue encendida...
                
                let isPcStillOn = true // Resultado de tu algoritmo
                
                if isPcStillOn {
                    triggerLocalNotification()
                    // Si sigue encendida insistimos antes (sugerimos al sistema volver en 15 min)
                    scheduleNextCheck(delayInSeconds: 15 * 60)
                }
                
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false) // Provoca un .retry() automático
            }
        }
    }
    
    static func scheduleNextCheck(delayInSeconds: TimeInterval) {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        // Define el retraso mínimo equivalente al setInitialDelay de tu WorkManager
        request.earliestBeginDate = Date().addingTimeInterval(delayInSeconds)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BackgroundTasks: Próximo chequeo programado con éxito.")
        } catch {
            print("BackgroundTasks: No se pudo agendar la tarea: \(error)")
        }
    }
    
    private static func triggerLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "ControlH: Recordatorio"
        content.body = "Tu equipo sigue encendido. Por favor, apágalo al terminar."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
