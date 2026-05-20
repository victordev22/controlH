//
//  controlHApp.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//



import SwiftUI
import UserNotifications

// Estado global de la app equivalente al companion object de MyApp
class AppState: ObservableObject {
    static let shared = AppState()
    @Published var currentUser: User? = nil
    
    private init() {}
    
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
    }
}

// El AppDelegate gestiona permisos y registros del APNS de Apple (Notificaciones push)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        TokenManager.shared.initManager()
        registerForRemoteNotifications()
        return true
    }
    
    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Solicita permisos nativos de alertas de forma asíncrona (reemplaza checkAndRequestPermissions)
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permiso de notificaciones concedido.")
                DispatchQueue.main.onMainActor {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permiso de notificaciones denegado.")
            }
        }
    }
    
    // Callback cuando Apple te otorga el Device Token único para emparejar con Novu
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token de Apple obtenido: \(tokenString)")
        // Aquí invocas a NovuManager.vincularDispositivo(email: ..., fcmToken: tokenString)
    }
}

@main
struct ControlHApp: App {
    // Vincula el ciclo de vida del sistema nativo a SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppState.shared)
        }
    }
}
