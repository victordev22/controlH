//
//  PowerOnOf.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct PowerOnOf: View {
    let viewModel: ControlViewModel

    private var buttonColor: Color {
        viewModel.uiState.isPoweredOn ? Color(hex: "43A047") : Color(hex: "E53935")
    }

    var body: some View {
        VStack(spacing: 20) {

            Button(action: { viewModel.togglePower() }) {
                ZStack {
                    Circle()
                        .fill(buttonColor)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.uiState.isPoweredOn)

                    if viewModel.uiState.isConnecting {
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
            .disabled(viewModel.uiState.isConnecting)

            Spacer().frame(height: 12)

            Text("Status: \(viewModel.uiState.isPoweredOn ? "On" : "Off")")
                .font(.title2)
                .fontWeight(.medium)

            if let error = viewModel.uiState.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
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
        PowerOnOf(viewModel: ControlViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
