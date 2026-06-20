//
//  ExhibitContentService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

final class ExhibitContentService {
    private let wikipediaService = WikipediaService()
    private let gbifService = GBIFService()

    func loadDisplayItems(for exhibit: Exhibit) async -> [DisplayItem] {
        var displayItems: [DisplayItem] = []

        for seed in exhibit.displaySeeds {
            let displayItem = await loadDisplayItem(from: seed)
            displayItems.append(displayItem)
        }

        return displayItems
    }

    private func loadDisplayItem(from seed: DisplaySeed) async -> DisplayItem {
        async let wikipediaResult = fetchWikipediaSummarySafely(for: seed.wikipediaTitle)
        async let gbifResult = fetchGBIFDataSafely(for: seed.gbifSearchName ?? seed.title)

        let wikipediaResponse = await wikipediaResult
        let gbifData = await gbifResult

        if let wikipediaResponse {
            return makeDisplayItem(
                from: wikipediaResponse,
                seed: seed,
                gbifData: gbifData
            )
        } else {
            return makeFallbackDisplayItem(
                from: seed,
                gbifData: gbifData
            )
        }
    }

    private func fetchWikipediaSummarySafely(for title: String) async -> WikipediaSummaryResponse? {
        do {
            return try await wikipediaService.fetchSummary(for: title)
        } catch {
            print("Wikipedia fetch failed for \(title): \(error)")
            return nil
        }
    }

    private func fetchGBIFDataSafely(for name: String) async -> GBIFData? {
        do {
            let gbifData = try await gbifService.fetchSpeciesMatch(for: name)
            return gbifData.hasUsefulData ? gbifData : nil
        } catch {
            print("GBIF fetch failed for \(name): \(error)")
            return nil
        }
    }

    private func makeDisplayItem(
        from response: WikipediaSummaryResponse,
        seed: DisplaySeed,
        gbifData: GBIFData?
    ) -> DisplayItem {
        let extract = response.extract ?? "Information is currently unavailable."
        let shortDescription = response.description ?? makeShortDescription(from: extract)
        let imageUrl = URL(string: response.thumbnail?.source ?? "")
        let sourceUrl = URL(string: response.contentUrls?.desktop?.page ?? "")

        return DisplayItem(
            id: seed.id,
            title: response.title,
            shortDescription: shortDescription,
            detailedDescription: extract,
            funFacts: makeFunFacts(from: extract, gbifData: gbifData),
            imageUrl: imageUrl,
            sourceUrl: sourceUrl,
            attributionText: "Summary and image from Wikipedia. Scientific classification from Global Biodiversity Information Facility (GBIF).",
            gbifData: gbifData
        )
    }

    private func makeFallbackDisplayItem(
        from seed: DisplaySeed,
        gbifData: GBIFData?
    ) -> DisplayItem {
        DisplayItem(
            id: seed.id,
            title: seed.title,
            shortDescription: "Information could not be fully loaded right now.",
            detailedDescription: "Please check your internet connection and try reloading the experience.",
            funFacts: makeFunFacts(from: "", gbifData: gbifData),
            imageUrl: nil,
            sourceUrl: nil,
            attributionText: gbifData == nil ? "Offline content" : "Taxonomy data source: GBIF",
            gbifData: gbifData
        )
    }

    private func makeShortDescription(from text: String) -> String {
        if text.count <= 120 { return text }
        let endIndex = text.index(text.startIndex, offsetBy: 120)
        return String(text[..<endIndex]) + "..."
    }

    private func makeFunFacts(from extract: String, gbifData: GBIFData?) -> [String] {
        var facts: [String] = []

        if let gbifData {
            if let canon = gbifData.canonicalName {
                facts.append("The scientific identifier for this specimen is \(canon).")
            }
            if let taxonomicClass = gbifData.taxonomicClass {
                facts.append("It is physiologically categorized under the biological class \(taxonomicClass).")
            }
            if let family = gbifData.family {
                facts.append("It occupies taxonomic status within the family of \(family).")
            }
        }

        let sentences = extract
            .components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for sentence in sentences.prefix(3) {
            let fact = sentence.hasSuffix(".") ? sentence : sentence + "."
            facts.append(fact)
        }

        if facts.isEmpty {
            return [
                "This specimen represents an integral piece of the Earth's natural history.",
                "The Canadian Museum of Nature preserves samples like this for research and discovery.",
                "Every artifact tells an evolutionary story millions of years in the making."
            ]
        }

        return Array(facts.prefix(5))
    }
}
