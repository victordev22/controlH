//
//  NovuCredentials.swift
//  controlH
//
//  Created by user297436 on 5/19/26.
//

import Foundation

struct NovuCredentialsRequest: Codable {
    let providerId: String
    let deviceTokens: [String]

    enum CodingKeys: String, CodingKey {
        case providerId = "providerId"
        case deviceTokens = "deviceTokens"
    }
}

struct NovuCredentialsWrapper: Codable {
    let credentials: NovuCredentialsRequest
}
