//
//  UserProgressService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation
import Combine

final class UserProgressService: ObservableObject {
    @Published var progress = UserProgress.default
    private let defaultsKey = "UserProgressData"
    private let badgeDataService = BadgeDataService()
    
    init() {
        loadProgress()
    }

    private func loadProgress() {
        if let savedData = UserDefaults.standard.data(forKey: defaultsKey) {
            if let decodedProgress = try? JSONDecoder().decode(UserProgress.self, from: savedData) {
                progress = decodedProgress
            }
        }
    }

    func saveProgress() {
        if let encodedData = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encodedData, forKey: defaultsKey)
        }
    }

    func earnBadge(_ badge: Badge) {
        if !progress.hasEarned(badge.id) {
            progress.earnedBadges.append(badge.id)
            saveProgress()
        }
    }

    func completeQuiz(for exhibitId: String) {
        if !progress.hasCompletedQuiz(for: exhibitId) {
            progress.completedQuizzes[exhibitId] = true
            saveProgress()
        }
    }

    // This is only so the quiz completion logic is clear. Later, this might decide *which* badge to award.
    func awardQuizCompletionBadge(for exhibitId: String, badgeId: String) {
        let allBadges = badgeDataService.loadBadges() // Synchronous call
        if let badgeToAward = allBadges.first(where: { $0.id == badgeId }) {
            // Check if the quiz for this exhibit is completed AND the badge is not already earned
            if progress.hasCompletedQuiz(for: exhibitId) && !progress.hasEarned(badgeToAward.id) {
                earnBadge(badgeToAward) // This method updates progress and saves
            }
        }
    }
    
    /// Wipes all saved progress, badges, and quiz completions
    func resetProgress() {
        // Reset local object state
        self.progress = UserProgress.default
        
        // Remove the data from persistent storage
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        
        // Explicitly notify any SwiftUI ViewModels watching this service
        objectWillChange.send()
        
        print("User progress successfully cleared and reset.")
    }
}
