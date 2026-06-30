//
//  WikipediaImageService.swift
//  iOSApp3
//
//  Lightweight fallback image resolver using Wikipedia page images API.
//  Used when curated and GBIF image sources are unavailable.
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

/// Actor-based Wikipedia image lookup service with in-memory query cache.
actor WikipediaImageService {
    /// Shared singleton instance.
    static let shared = WikipediaImageService()
    
    /// Cache key: normalized query string, value: resolved image URL (or nil if lookup failed).
    private var cache: [String: URL?] = [:]

    /// Resolves a representative image URL for a query using Wikipedia's pageimages endpoint.
    /// - Parameter query: Species/common name search text.
    /// - Returns: First available original image URL, if found.
    func imageURL(for query: String) async -> URL? {
        let key = query.lowercased()
        if let cached = cache[key] { return cached }

        var comps = URLComponents(string: "https://en.wikipedia.org/w/api.php")
        comps?.queryItems = [
            .init(name: "action", value: "query"),
            .init(name: "format", value: "json"),
            .init(name: "prop", value: "pageimages"),
            .init(name: "piprop", value: "original"),
            .init(name: "redirects", value: "1"),
            .init(name: "titles", value: query)
        ]

        guard let url = comps?.url else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                cache[key] = nil
                return nil
            }

            let decoded = try await MainActor.run {
                try JSONDecoder().decode(WikiResponse.self, from: data)
            }
            let firstPage = decoded.query.pages.values.first
            let image = firstPage?.original?.source.flatMap(URL.init(string:))
            cache[key] = image
            return image
        } catch {
            cache[key] = nil
            return nil
        }
    }
}

/// Root response model for Wikipedia query API.
private struct WikiResponse: Decodable {
    let query: WikiQuery
}

/// Wrapper containing page dictionary keyed by page ID.
private struct WikiQuery: Decodable {
    let pages: [String: WikiPage]
}

/// Minimal page model containing optional original image.
private struct WikiPage: Decodable {
    let original: WikiOriginal?
}

/// Original image payload from pageimages API.
private struct WikiOriginal: Decodable {
    let source: String?
}
