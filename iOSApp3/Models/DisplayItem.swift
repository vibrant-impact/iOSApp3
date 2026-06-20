//
//  DisplayItem.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

// Information for each display in each gallery
struct DisplayItem: Identifiable {
    let id: String
    let title: String
    let shortDescription: String
    let detailedDescription: String
    let funFacts: [String]
    let imageUrl: URL?
    let sourceUrl: URL?
    let attributionText: String
    let gbifData: GBIFData?
}
