//
//  SwitchWithLabel.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import SwiftUI

struct SwitchWithLabel: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    
    @State private var isChecked: Bool
    // Callback equivalente a: (Boolean, (Boolean) -> Unit) -> Unit
    var onCheckChanged: (Bool, @escaping (Bool) -> Void) -> Void
    
    init(title: String, initialSwitchState: Bool, isLoading: Bool = false, isEnabled: Bool = true, onCheckChanged: @escaping (Bool, @escaping (Bool) -> Void) -> Void) {
        self.title = title
        self._isChecked = State(initialValue: initialSwitchState)
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.onCheckChanged = onCheckChanged
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(isEnabled ? .white : .gray.opacity(0.5))
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 50, height: 30)
            } else {
                // Interceptamos la actualización del Toggle mediante un Binding calculado
                Toggle("", isOn: Binding(
                    get: { self.isChecked },
                    set: { newValue in
                        // 1. Actualización optimista de la UI instantánea
                        self.isChecked = newValue
                        
                        // 2. Disparamos la llamada de red asíncrona pasándole el callback de respuesta
                        self.onCheckChanged(newValue) { success in
                            if !success {
                                // 3. Si la operación falló en el servidor, revertimos al estado anterior
                                self.isChecked = !newValue
                            }
                        }
                    }
                ))
                .labelsHidden() // Oculta la etiqueta vacía nativa del Toggle
                .disabled(!isEnabled)
                .tint(.red) // Color de fondo activo (checkedTrackColor)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - PREVIEWS
struct SwitchWithLabel_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SwitchWithLabel(title: "Enable Feature", initialSwitchState: true) { isChecked, callback in
                print("Modificado a: \(isChecked)")
                // Simulamos una respuesta exitosa del servidor tras 1 segundo
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    callback(true)
                }
            }
            
            SwitchWithLabel(title: "Loading...", initialSwitchState: false, isLoading: true) { _, _ in }
        }
        .padding()
        .background(Color.black)
    }
}
