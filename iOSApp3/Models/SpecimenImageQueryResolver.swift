//
//  SpecimenImageQueryResolver.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

/// Builds optimized fallback text queries for image lookup services.
enum SpecimenImageQueryResolver {
    /// Returns a query string for image discovery.
    /// Uses explicit ID overrides first, then scientific name, then title.
    static func query(for item: DisplayItem) -> String {
        if let override = overrides[item.id] { return override }
        return item.gbifData?.scientificName ?? item.title
    }

    /// Manual query overrides for IDs where title/scientific names are weak or ambiguous.
    private static let overrides: [String: String] = [
        // Missing ones you listed
        "bug_2": "Grammostola rosea",
        "fos_1": "Daspletosaurus",
        "fos_5": "Chasmosaurus",
        "fos_6": "Spiclypeus",
        "fos_7": "Elasmosaurus",
        "fos_8": "Mosasaur",
        "fos_9": "Chasmosaurus",
        "fos_11": "Camelops",
        "fos_12": "Woolly mammoth",
        "wat_1": "Blue whale",
        "wat_11": "Mytilus edulis",
        "wat_12": "Seabird",
        "mam_1": "Plains bison",
        "mam_2": "Gray Wolf Pack",
        "mam_3": "Grizzly Bear",
        "mam_5": "Bull Moose",
        "mam_6": "Barren-ground caribou",
        "mam_8": "Mountain Goat",
        "mam_9": "Polar Bear",
        "mam_10": "Ringed Seal",
        "ear_1": "Moon rock",
        "ear_3": "Mont Saint-Hilaire",
        "ear_4": "Amethyst",
        "ear_6": "Sudbury Basin",
        "ear_7": "Sulfur",
        "ear_8": "Azurite",
        "ear_11": "Limestone",
        "ear_12": "Fluorescence",
        "bir_11": "Bird nest",
        "arc_1": "Ice sculpture",
        "arc_2": "Aurora",
        "arc_9": "Franklin's lost expedition",
        "arc_10": "Yupʼik cuisine",
        "arc_11": "Inuit weapons"
        
    ]
}
