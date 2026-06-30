//
//  GBIFImageService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

/// Actor-based service that resolves remote image URLs from GBIF occurrence endpoints.
/// Includes in-memory caching to reduce repeated network calls.
actor GBIFImageService {
    
    /// Shared singleton instance.
    static let shared = GBIFImageService()

    private var cache: [String: URL?] = [:]

    /// Resolves an image URL for a specimen, using cached value if available.
    func imageURL(for item: DisplayItem) async -> URL? {
        if let cached = cache[item.id] { return cached }

        let url: URL?
        if let usageKey = item.gbifData?.usageKey {
            url = await fetchByTaxonKey(usageKey)
        } else {
            let query = item.gbifData?.scientificName ?? item.title
            url = await fetchByScientificName(query)
        }

        cache[item.id] = url
        return url
    }

    /// Searches GBIF occurrences by taxon key.
    private func fetchByTaxonKey(_ taxonKey: Int) async -> URL? {
        var comps = URLComponents(string: "https://api.gbif.org/v1/occurrence/search")
        comps?.queryItems = [
            URLQueryItem(name: "taxonKey", value: String(taxonKey)),
            URLQueryItem(name: "mediaType", value: "StillImage"),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = comps?.url else { return nil }
        return await fetchFirstMediaURL(from: url)
    }

    /// Searches GBIF occurrences by scientific name.
    private func fetchByScientificName(_ name: String) async -> URL? {
        var comps = URLComponents(string: "https://api.gbif.org/v1/occurrence/search")
        comps?.queryItems = [
            URLQueryItem(name: "scientificName", value: name),
            URLQueryItem(name: "mediaType", value: "StillImage"),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = comps?.url else { return nil }
        return await fetchFirstMediaURL(from: url)
    }

    /// Parses occurrence results and returns first likely usable image URL.
    private func fetchFirstMediaURL(from endpoint: URL) async -> URL? {
        do {
            let (data, response) = try await URLSession.shared.data(from: endpoint)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return nil
            }

            let decoded = try await MainActor.run {
                try JSONDecoder().decode(GBIFOccurrenceSearchResponse.self, from: data)
            }

            for occurrence in decoded.results {
                for media in occurrence.media ?? [] {
                    guard let raw = media.identifier?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !raw.isEmpty,
                          var mediaURL = URL(string: raw) else { continue }

                    // Normalize HTTP -> HTTPS when possible
                    if mediaURL.scheme == "http",
                       let https = URL(string: raw.replacingOccurrences(of: "http://", with: "https://")) {
                        mediaURL = https
                    }

                    if isLikelyImageURL(mediaURL) {
                        return mediaURL
                    }
                }
            }
        } catch {
            print("🧪 [GBIFImageService] error: \(error.localizedDescription)")
        }

        return nil
    }

    /// Heuristic filter for common image URL patterns/extensions.
    private func isLikelyImageURL(_ url: URL) -> Bool {
        let path = url.path.lowercased()
        return path.hasSuffix(".jpg")
            || path.hasSuffix(".jpeg")
            || path.hasSuffix(".png")
            || path.hasSuffix(".webp")
            || path.hasSuffix(".gif")
            || path.contains("/image")
            || path.contains("/images")
    }
}

private struct GBIFOccurrenceSearchResponse: Decodable {
    let results: [GBIFOccurrence]
}

private struct GBIFOccurrence: Decodable {
    let media: [GBIFMedia]?
}

private struct GBIFMedia: Decodable {
    let identifier: String?
}
