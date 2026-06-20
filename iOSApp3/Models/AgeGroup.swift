//
//  AgeGroup.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

// Sets audio guide style according to age group selection
enum AgeGroup: String, CaseIterable, Identifiable, Codable {
    case child = "Child"
    case teen = "Teen"
    case adult = "Adult"

    var id: String {
        rawValue
    }

    var description: String {
        switch self {
        case .child:
            return "Simple, fun, and curious"
        case .teen:
            return "More detailed with cool facts"
        case .adult:
            return "Informative and museum-style"
        }
    }
}
