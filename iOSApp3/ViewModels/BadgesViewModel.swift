//
//  BadgesViewModel.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation
import Combine

@MainActor
final class BadgesViewModel: ObservableObject {
    @Published var availableBadges: [Badge] = []
    @Published var earnedBadges: [Badge] = []
    @Published private(set) var hasLoadedBadgeDefinitions = false
    
    private let badgeDataService = BadgeDataService()
    private var allPossibleBadges: [Badge] = []
    let userProgressService: UserProgressService
    private var cancellables = Set<AnyCancellable>()
    
    init(userProgressService: UserProgressService) {
        self.userProgressService = userProgressService
        self.allPossibleBadges = badgeDataService.loadBadges()
        self.hasLoadedBadgeDefinitions = !self.allPossibleBadges.isEmpty
        print("--- BadgesViewModel: Initial load complete. Found \(self.allPossibleBadges.count) total possible badges. ---")
        reapplyProgressAndSortBadges()
        subscribeToProgressUpdates()
    }
    
    func loadBadges() async {
        print("--- BadgesViewModel: loadBadges() called via .task ---")
        if allPossibleBadges.isEmpty {
            print("   Defensively loading badges again as allPossibleBadges is empty.")
            self.allPossibleBadges = badgeDataService.loadBadges()
        }
        hasLoadedBadgeDefinitions = !allPossibleBadges.isEmpty
        reapplyProgressAndSortBadges()
        print("--- BadgesViewModel: .task load complete. Available: \(availableBadges.count), Earned: \(earnedBadges.count) ---")
    }
    
    private func subscribeToProgressUpdates() {
        userProgressService.$progress
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reapplyProgressAndSortBadges()
            }
            .store(in: &cancellables)
    }
    
    private func reapplyProgressAndSortBadges() {
        let updatedBadges = self.allPossibleBadges.map { badge in
            var updatedBadge = badge
            updatedBadge.isEarned = userProgressService.progress.hasEarned(badge.id)
            return updatedBadge
        }
        
        let earnedOnly = updatedBadges.filter { $0.isEarned }
        self.availableBadges = earnedOnly
        updateEarnedBadges()
        hasLoadedBadgeDefinitions = !allPossibleBadges.isEmpty
        print("reapplyProgressAndSortBadges: Available: \(availableBadges.count), Earned: \(earnedBadges.count)")
    }
    
    private func updateEarnedBadges() {
        
        earnedBadges = availableBadges
        print("BadgesViewModel: Updated earnedBadges count: \(earnedBadges.count)")
    }
}
