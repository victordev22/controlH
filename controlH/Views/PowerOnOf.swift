//
//  PowerOnOf.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct PowerOnOf: View {
    // Simulación del estado del ViewModel
    @State private var uiState = PowerUiState()
    
    // Computamos los colores nativos en base a tus valores hexadecimales de Android
    private var buttonColor: Color {
        uiState.isPoweredOn ? Color(hex: "43A047") : Color(hex: "E53935")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Botón Circular con Sombra (Elevación de 8.dp)
            Button(action: {
                togglePowerSimulated()
            }) {
                ZStack {
                    Circle()
                        .fill(buttonColor)
                        // Controla de forma nativa e implícita el cambio de color animado
                        .animation(.easeInOut(duration: 0.3), value: uiState.isPoweredOn)
                    
                    if uiState.isConnecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: "power")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 120, height: 120)
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            // Inhabilita interacciones múltiples previniendo spam de clics
            .disabled(uiState.isConnecting)
            
            Spacer()
                .frame(height: 12)
            
            // Texto descriptivo del estado actual
            Text("Status: \(uiState.isPoweredOn ? "On" : "Off")")
                .font(.title2)
                .fontWeight(.medium)
        }
    }
    
    // Simulación del disparador asíncrono del ViewModel (togglePower)
    private func togglePowerSimulated() {
        uiState.isConnecting = true
        
        // Simulamos el tiempo de espera de la petición de red (Retrofit equivalente)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            uiState.isPoweredOn.toggle()
            uiState.isConnecting = false
        }
    }
}

// MARK: - EXTENSIÓN PARA SOPORTE DE COLORES HEXADECIMALES
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - PREVIEW
struct PowerOnOf_Previews: PreviewProvider {
    static var previews: some View {
        PowerOnOf()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
