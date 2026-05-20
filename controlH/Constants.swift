//
//  Constants.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation

struct Constants {
    static let baseURL  = "https://control.meta4bim.com/"
    static let baseAuth = "https://auth.meta4bim.com/"
    static let baseOn   = "https://onoffice.powerbim.io/"
    static let baseSsh  = "http://4.245.225.143:8087/api/ssh/execute?command="

    static let pathHoras    = "control/listhoras"
    static let pathUser     = "auth/admin/list"

    // Límites de tiempo de uso (en minutos)
    static let dailyMaxMinutes  = 480   // 8 horas
    static let weeklyMaxMinutes = 2400  // 40 horas
}
