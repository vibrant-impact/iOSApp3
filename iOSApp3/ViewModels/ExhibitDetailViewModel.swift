//
//  ExhibitDetailViewModel.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation
import Combine

@MainActor
final class ExhibitDetailViewModel: ObservableObject {
    @Published var displayItems: [DisplayItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let exhibit: Exhibit
    private let exhibitContentService = ExhibitContentService()
    let userProgressService: UserProgressService
    
    init(exhibit: Exhibit, userProgressService: UserProgressService) {
        self.exhibit = exhibit
        self.userProgressService = userProgressService
    }

    func loadDisplayItems() async {
        isLoading = true
        errorMessage = nil

        let items = await exhibitContentService.loadDisplayItems(for: exhibit)

        displayItems = items

        if items.isEmpty {
            errorMessage = "No displays could be loaded."
        }

        isLoading = false
    }
}
