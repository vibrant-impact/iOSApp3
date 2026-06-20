//
//  Badge.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    var isEarned: Bool = false // Tracks view status dynamically in the ViewModel

    // Instruct the decoder to ignore 'isEarned' when decoding the JSON
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageName
    }
}
