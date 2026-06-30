//
//  GBIFDiscoveryService+GlobalSearch.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-27.
//

import Foundation

extension GBIFDiscoveryService {
    /// Executes live global GBIF search for occurrence records with images.
    ///
    /// Strategy:
    /// 1) Resolve best `taxonKey` via species suggest endpoint
    /// 2) Query occurrences by taxon for relevance
    /// 3) Fallback to plain text occurrence search
    func searchGBIFGlobal(query: String, limit: Int = 80, offset: Int = 0) async throws -> [DisplayItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= 2 else { return [] }

        // 1) Try species suggest for relevance
        if let taxonKey = try await bestTaxonKey(for: q) {
            let byTaxon = try await fetchOccurrences(taxonKey: taxonKey, limit: limit, offset: offset)
            if !byTaxon.isEmpty {
                print("🌍 GBIF GLOBAL taxonKey=\(taxonKey) query='\(q)' results=\(byTaxon.count)")
                return byTaxon
            }
        }

        // 2) Fallback to text query
        let byQuery = try await fetchOccurrences(query: q, limit: limit, offset: offset)
        print("🌍 GBIF GLOBAL fallback query='\(q)' results=\(byQuery.count)")
        return byQuery
    }

    // MARK: - Private helpers

    /// Attempts to find a best-fit GBIF taxon key for the user query.
    private func bestTaxonKey(for query: String) async throws -> Int? {
        var comps = URLComponents(string: "https://api.gbif.org/v1/species/suggest")!
        comps.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "10")
        ]

        let (data, response) = try await URLSession.shared.data(from: comps.url!)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            return nil
        }

        let rows = try JSONDecoder().decode([GBIFSpeciesSuggest].self, from: data)

        let preferred = rows.first(where: { row in
            let rank = (row.rank ?? "").lowercased()
            let status = (row.taxonomicStatus ?? "").lowercased()
            let rankOK = rank == "species" || rank == "genus" || rank == "family"
            let statusOK = status.isEmpty || status == "accepted"
            return rankOK && statusOK && row.key != nil
        })

        return preferred?.key ?? rows.first?.key
    }

    /// Fetches occurrence rows either by `taxonKey` or text `query`.
    /// Maps GBIF response rows into app `DisplayItem` models.
    private func fetchOccurrences(
        taxonKey: Int? = nil,
        query: String? = nil,
        limit: Int,
        offset: Int
    ) async throws -> [DisplayItem] {
        var comps = URLComponents(string: "https://api.gbif.org/v1/occurrence/search")!
        var items: [URLQueryItem] = [
            URLQueryItem(name: "mediaType", value: "StillImage"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        if let taxonKey {
            items.append(URLQueryItem(name: "taxonKey", value: String(taxonKey)))
        } else if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "q", value: query))
        }

        comps.queryItems = items

        let (data, response) = try await URLSession.shared.data(from: comps.url!)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(GBIFOccurrenceSearchRoot.self, from: data)

        return decoded.results.map { r in
            let occId = r.key.map(String.init) ?? UUID().uuidString
            let image = r.media?
                .compactMap(\.identifier)
                .compactMap(URL.init(string:))
                .first

            let title = r.vernacularName ?? r.species ?? r.scientificName ?? "GBIF Specimen"
            let short = [r.family, r.country].compactMap { $0 }.joined(separator: " • ")

            let gbif = GBIFData(
                usageKey: r.taxonKey,
                scientificName: r.scientificName,
                canonicalName: r.species,
                rank: r.taxonRank,
                kingdom: r.kingdom,
                phylum: r.phylum,
                taxonomicClass: r.className,
                order: r.order,
                family: r.family,
                genus: r.genus
            )

            return DisplayItem(
                id: "gbif_occ_\(occId)",
                title: title,
                shortDescription: short.isEmpty ? "GBIF occurrence" : short,
                detailedDescription: """
                Live GBIF occurrence record.
                Dataset: \(r.datasetName ?? "Unknown")
                Basis: \(r.basisOfRecord ?? "Unknown")
                """,
                funFacts: [
                    "Occurrence key: \(r.key ?? 0)",
                    "Taxon key: \(r.taxonKey ?? 0)",
                    "Country: \(r.country ?? "Unknown")"
                ],
                imageUrl: image,
                sourceUrl: r.key.flatMap { URL(string: "https://www.gbif.org/occurrence/\($0)") },
                attributionText: r.rightsHolder ?? "GBIF",
                gbifData: gbif
            )
        }
    }
}

// MARK: - DTOs

private struct GBIFSpeciesSuggest: Decodable {
    let key: Int?
    let rank: String?
    let taxonomicStatus: String?
}

private struct GBIFOccurrenceSearchRoot: Decodable {
    let results: [GBIFOccurrenceRow]
}

private struct GBIFOccurrenceRow: Decodable {
    let key: Int?
    let taxonKey: Int?
    let scientificName: String?
    let species: String?
    let vernacularName: String?
    let taxonRank: String?
    let kingdom: String?
    let phylum: String?
    let order: String?
    let family: String?
    let genus: String?
    let country: String?
    let datasetName: String?
    let basisOfRecord: String?
    let rightsHolder: String?
    let media: [GBIFOccurrenceMedia]?
    let className: String?

    enum CodingKeys: String, CodingKey {
        case key, taxonKey, scientificName, species, vernacularName, taxonRank
        case kingdom, phylum, order, family, genus, country, datasetName, basisOfRecord, rightsHolder, media
        case className = "class"
    }
}

private struct GBIFOccurrenceMedia: Decodable {
    let identifier: String?
}
