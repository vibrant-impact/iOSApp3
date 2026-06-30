//
//  GBIFDiscoveryService+Search.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-28.
//

import Foundation

extension GBIFDiscoveryService {
    /// Returns curated featured specimens for a specific gallery.
    func featuredSpecimens(for gallery: MuseumGallery) -> [DisplayItem] {
        fetchGallerySpecimens(gallery: gallery, query: "")
    }
}
