//
//  DisplayItem.swift
//  iOSApp3
//
//  Core presentation model used by gallery views, search results, and detail sheets.
//  Supports both curated museum records and live GBIF occurrence records.
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

/// Backward-compatibility alias for legacy naming in older files.
typealias GBifTaxonData = GBIFData

extension GBIFData {
    /// Convenience initializer for legacy call sites that provide only core taxonomy fields.
    /// - Note: This intentionally sets `usageKey` and `genus` to `nil`.
    init(
        rank: String?,
        scientificName: String?,
        kingdom: String?,
        phylum: String?,
        taxonomicClass: String?,
        order: String?,
        family: String?
    ) {
        self.init(
            usageKey: nil,
            scientificName: scientificName,
            canonicalName: scientificName,
            rank: rank,
            kingdom: kingdom,
            phylum: phylum,
            taxonomicClass: taxonomicClass,
            order: order,
            family: family,
            genus: nil
        )
    }
}

/// Unified specimen/card model rendered throughout the app.
///
/// This model intentionally supports:
/// 1. Curated museum records (`bug_`, `fos_`, etc.)
/// 2. Live GBIF records (`gbif_occ_...`)
struct DisplayItem: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let shortDescription: String
    let detailedDescription: String
    let funFacts: [String]
    let imageUrl: URL?
    let sourceUrl: URL?
    let attributionText: String
    let gbifData: GBIFData?

    /// Alias used by older UI code paths.
    var commonName: String { title }
    /// Uses taxonomic scientific name when available.
    var scientificName: String { gbifData?.scientificName ?? title }
    /// Convenience taxonomy accessor for chips/labels.
    var family: String? { gbifData?.family }
    /// Legacy field alias retained for compatibility.
    var idField: String { id }

    /// Preferred image resolution path:
    /// 1) curated in-app catalogue URL
    /// 2) dynamic `imageUrl` from remote source (GBIF/Wikipedia/etc.)
    var imageURL: URL? {
        SpecimenImageCatalogue.url(for: id) ?? imageUrl
    }

    /// Designated initializer with URL sanitization.
    init(
        id: String,
        title: String,
        shortDescription: String,
        detailedDescription: String,
        funFacts: [String],
        imageUrl: URL?,
        sourceUrl: URL?,
        attributionText: String,
        gbifData: GBIFData? = nil
    ) {
        self.id = id
        self.title = title
        self.shortDescription = shortDescription
        self.detailedDescription = detailedDescription
        self.funFacts = funFacts
        self.imageUrl = Self.sanitize(imageUrl)
        self.sourceUrl = sourceUrl
        self.attributionText = attributionText
        self.gbifData = gbifData
    }

    /// Custom coding keys intentionally exclude `gbifData` for curated payload compatibility.
    enum CodingKeys: String, CodingKey {
        case id, title, shortDescription, detailedDescription, funFacts, imageUrl, sourceUrl, attributionText
    }

    /// URL sanitizer to reject deprecated/undesired image hosts.
    private static func sanitize(_ url: URL?) -> URL? {
        guard let url else { return nil }
        let host = url.host?.lowercased() ?? ""
        if host.contains("unsplash.com") { return nil } // block old random source
        return url
    }

    /// Decodes curated payload while sanitizing image URLs.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        shortDescription = try c.decode(String.self, forKey: .shortDescription)
        detailedDescription = try c.decode(String.self, forKey: .detailedDescription)
        funFacts = try c.decode([String].self, forKey: .funFacts)

        let rawImageUrl = try c.decodeIfPresent(URL.self, forKey: .imageUrl)
        imageUrl = Self.sanitize(rawImageUrl)

        sourceUrl = try c.decodeIfPresent(URL.self, forKey: .sourceUrl)
        attributionText = try c.decode(String.self, forKey: .attributionText)
        gbifData = nil
    }

    /// Encodes only curated-compatible fields.
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(shortDescription, forKey: .shortDescription)
        try c.encode(detailedDescription, forKey: .detailedDescription)
        try c.encode(funFacts, forKey: .funFacts)
        try c.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try c.encodeIfPresent(sourceUrl, forKey: .sourceUrl)
        try c.encode(attributionText, forKey: .attributionText)
    }
}
