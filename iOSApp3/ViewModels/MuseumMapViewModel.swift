//
//  MuseumMapViewModel.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation
import Combine

// Map showing exhibits to visit within the museum
@MainActor
final class MuseumMapViewModel: ObservableObject {
    @Published var exhibits: [Exhibit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let exhibitDataService = ExhibitDataService()

    func loadExhibits() async {
        isLoading = true
        errorMessage = nil

        do {
            exhibits = try await exhibitDataService.loadExhibits()
        } catch {
            errorMessage = "Could not load exhibits."
        }

        isLoading = false
    }
}
