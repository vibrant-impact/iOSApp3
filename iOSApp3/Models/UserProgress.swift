//
//  UserProgress.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation

struct UserProgress: Codable {
    var earnedBadges: [String] = [] // Store badge IDs
    var completedQuizzes: [String: Bool] = [:] // exhibitId: Bool indicating completion

    static var `default`: UserProgress {
        UserProgress() // Starts with no earned badges or completed quizzes
    }

    // Helper to check if a badge is earned
    func hasEarned(_ badgeId: String) -> Bool {
        earnedBadges.contains(badgeId)
    }

    // Helper to check if a quiz is completed
    func hasCompletedQuiz(for exhibitId: String) -> Bool {
        completedQuizzes[exhibitId] == true
    }
}
