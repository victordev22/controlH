//
//  HorasUiState.swift
//  controlH
//
//  Created by user297436 on 5/20/26.
//

import Foundation

enum HorasUiState {
    case initial
    case loading
    case success(horas: [Horas])
    case error(message: String)
}
