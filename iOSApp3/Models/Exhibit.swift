//
//  Exhibit.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation
import CoreGraphics

// Information for each gallery in the museum
struct Exhibit: Identifiable, Codable {
    let id: String
    let name: String
    let floor: Int
    let theme: String
    let mapX: Double
    let mapY: Double
    let summary: String
    let displaySeeds: [DisplaySeed]
}
