//
//  GBIFModels.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

/// Normalized taxonomic metadata used by UI cards and detail views.
struct GBIFData: Codable, Hashable {
    let usageKey: Int?
    let scientificName: String?
    let canonicalName: String?
    let rank: String?
    let kingdom: String?
    let phylum: String?
    let taxonomicClass: String?
    let order: String?
    let family: String?
    let genus: String?

    /// Indicates whether this model has at least one non-empty useful taxonomy field.
    var hasUsefulData: Bool {
        scientificName != nil ||
        canonicalName != nil ||
        kingdom != nil ||
        phylum != nil ||
        taxonomicClass != nil ||
        order != nil ||
        family != nil ||
        genus != nil
    }
}

/// Raw response model for GBIF `/species/match` endpoint.
struct GBIFSpeciesMatchResponse: Decodable {
    let usageKey: Int?
    let scientificName: String?
    let canonicalName: String?
    let rank: String?
    let kingdom: String?
    let phylum: String?
    let taxonomicClass: String?
    let order: String?
    let family: String?
    let genus: String?
    let matchType: String?
    let confidence: Int?

    enum CodingKeys: String, CodingKey {
        case usageKey
        case scientificName
        case canonicalName
        case rank
        case kingdom
        case phylum
        case taxonomicClass = "class"
        case order
        case family
        case genus
        case matchType
        case confidence
    }

    /// Maps raw GBIF response model into app-level normalized `GBIFData`.
    func toGBIFData() -> GBIFData {
        GBIFData(
            usageKey: usageKey,
            scientificName: scientificName,
            canonicalName: canonicalName,
            rank: rank,
            kingdom: kingdom,
            phylum: phylum,
            taxonomicClass: taxonomicClass,
            order: order,
            family: family,
            genus: genus
        )
    }
}
