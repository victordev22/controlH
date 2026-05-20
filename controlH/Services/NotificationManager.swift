//
//  NotificationManager.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {}
    
    // Solicitar permisos al usuario (Sustituye la configuración manual del canal de Android)
    func requestPermissions() {
        UNUserNotificationCenter.current().requestPermission(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permisos de notificaciones concedidos.")
                // Registrar para notificaciones remotas en el hilo principal
                DispatchQueue.main.async {
                    #if os(iOS)
                    // Registrar el dispositivo con Apple (APNs) para obtener el token del dispositivo
                    // UIApplication.shared.registerForRemoteNotifications()
                    #endif
                }
            }
        }
    }
    
    // Captura la notificación cuando la App está abierta (Equivalente exacto a onMessageReceived)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // Extraer datos personalizados de Novu (Data Payload)
        if let pcName = userInfo["computerName"] as? String {
            print("Datos de Novu recibidos en segundo plano. Equipo encendido: \(pcName)")
        }
        
        // .banner hace que la notificación "salte" visualmente arriba de la pantalla incluso estando dentro de la app
        completionHandler([.banner, .sound, .list])
    }
}
