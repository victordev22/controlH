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
            Self.handleTaskExecution(processingTask)
        }
    }

    private static func handleTaskExecution(_ task: BGProcessingTask) {
        // Reprograma la siguiente ejecución antes de hacer trabajo
        scheduleNextCheck(delayInSeconds: 24 * 3600)

        Task {
            await checkAndNotifyIfNeeded()
            task.setTaskCompleted(success: true)
        }
    }

    // MARK: - Lógica principal: consulta API y dispara notificación si la PC sigue encendida fuera de horario

    static func checkAndNotifyIfNeeded() async {
        guard let token = TokenManager.getToken() else {
            print("NotificationWorker: sin token, omitiendo chequeo")
            return
        }
        ApiService.shared.jwtToken = token

        do {
            // 1. Obtener datos del usuario actual y lista de horas
            async let userTask   = ApiService.shared.getRawCurrentUserJson()
            async let horasTask  = ApiService.shared.getHoras()
            let (user, horasList) = try await (userTask, horasTask)

            // 2. Comprobar si el equipo del usuario sigue encendido (horaApagado == nil)
            let isPcOn = horasList.contains { hora in
                hora.horaApagado == nil &&
                hora.user.lowercased().contains(user.nickname.lowercased())
            }

            print("NotificationWorker: isPcOn=\(isPcOn) para usuario=\(user.nickname)")

            // 3. Si está encendido y fuera del horario configurado → notificar y recheck en 15 min
            if isPcOn, let offControl = user.ofControl, isOutsideScheduledHours(offControl: offControl) {
                triggerLocalNotification(nickname: user.nickname)
                scheduleNextCheck(delayInSeconds: 15 * 60)
            }
        } catch {
            print("NotificationWorker: error - \(error.localizedDescription)")
        }
    }

    // MARK: - Comprueba si la hora actual supera el horario de apagado

    private static func isOutsideScheduledHours(offControl: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let calendar   = Calendar.current
        let now        = Date()
        let nowMinutes = calendar.component(.hour, from: now) * 60
                       + calendar.component(.minute, from: now)

        guard let offDate = formatter.date(from: offControl) else { return false }
        let offMinutes = calendar.component(.hour, from: offDate) * 60
                       + calendar.component(.minute, from: offDate)

        return nowMinutes > offMinutes
    }

    // MARK: - Programación de la tarea en background

    static func scheduleNextCheck(delayInSeconds: TimeInterval) {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower       = false
        request.earliestBeginDate = Date().addingTimeInterval(delayInSeconds)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("NotificationWorker: próximo chequeo programado en \(Int(delayInSeconds / 60)) min")
        } catch {
            print("NotificationWorker: no se pudo agendar la tarea - \(error)")
        }
    }

    // MARK: - Notificación local

    private static func triggerLocalNotification(nickname: String) {
        let content      = UNMutableNotificationContent()
        content.title    = "ControlH: Equipo encendido fuera de horario"
        content.body     = "\(nickname), tu equipo sigue encendido. Por favor, apágalo."
        content.sound    = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("NotificationWorker: error al enviar notificación - \(error)")
            }
        }
    }
}
