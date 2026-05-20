//
//  UsageLimitProgress.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct UsageLimitProgress: View {
    let usedMinutes: Int
    let maxMinutes: Int
    let label: String
    var canvasSize: CGFloat = 150
    
    var foregroundIndicatorColor: Color {
        label == "Diario" ? AppTheme.primary : Color(red: 0.0, green: 0.78, blue: 0.32)
    }
    
    // Estado para disparar la animación de entrada de forma automática
    @State private var animationProgress: CGFloat = 0.0
    
    var body: some View {
        let remainingMinutes = max(maxMinutes - usedMinutes, 0)
        let maxTimeHours = maxMinutes / 60
        let percentage = CGFloat(min(usedMinutes, maxMinutes)) / CGFloat(maxMinutes)
        
        let smallText = remainingMinutes > 0 ? "Restantes de \(maxTimeHours)h (\(label))" : "Límite \(label) Alcanzado"
        
        VStack(spacing: 8) {
            ZStack {
                // 1. Arco de Fondo (Gris Tenue) - Rotado para simular tus 240 grados de arco abierto abajo
                Circle()
                    .trim(from: 0.0, to: 0.66)
                    .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(150))
                    .frame(width: canvasSize, height: canvasSize)
                
                // 2. Arco de Progreso (Color Activo Animado)
                Circle()
                    .trim(from: 0.0, to: 0.66 * (percentage * animationProgress))
                    .stroke(usedMinutes >= maxMinutes ? Color.red : foregroundIndicatorColor,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(150))
                    .frame(width: canvasSize, height: canvasSize)
                
                // 3. Textos Centrales Incrustados (EmbeddedElements)
                VStack(spacing: 2) {
                    Text(smallText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(width: canvasSize - 20)
                    
                    Text("\(usedMinutes) min")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(usedMinutes >= maxMinutes ? .red : foregroundIndicatorColor)
                }
            }
        }
        .onAppear {
            // Animación equivalente al tween(1000) de Compose
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
}
