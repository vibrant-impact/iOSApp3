//
//  QuizViewModel.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var quizCompleted = false
    @Published var score = 0
    @Published var showAnswerFeedback = false
    @Published var feedbackMessage = ""
    @Published var feedbackColor: Color = .green

    let exhibitId: String // To know which exhibit this quiz is for
    private let quizDataService = QuizDataService()
    let userProgressService: UserProgressService // Inject dependency

    private var cancellables = Set<AnyCancellable>()
    private lazy var badgeDataService = BadgeDataService()
    
    init(exhibitId: String, userProgressService: UserProgressService) {
        self.exhibitId = exhibitId
        self.userProgressService = userProgressService
        // Check if quiz is already completed for this exhibit
        self.quizCompleted = userProgressService.progress.hasCompletedQuiz(for: exhibitId)
    }

    var currentQuestion: QuizQuestion? {
        guard !questions.isEmpty, currentQuestionIndex < questions.count else {
            return nil
        }
        return questions[currentQuestionIndex]
    }

    func loadQuestions() async {
        do {
            let allQuestions = try await quizDataService.loadQuizQuestions()
            questions = allQuestions.filter { $0.exhibitId == exhibitId }
            if questions.isEmpty {
                // Handle case where there are no questions for this exhibit, maybe mark as completed?
                quizCompleted = true
            } else {
                // if it's completed, then we loaded it from disk, so no need to reset quiz state.
                if !userProgressService.progress.hasCompletedQuiz(for: exhibitId) {
                    currentQuestionIndex = 0
                    selectedAnswerIndex = nil
                    quizCompleted = false
                    score = 0
                } else {
                    // If already completed, let's set the UI to show it's done.
                    quizCompleted = true
                }
            }
        } catch {
            // Handle error: e.g., show an alert
            print("Error loading quiz questions: \(error)")
        }
    }

    func selectAnswer(_ answerIndex: Int) {
        selectedAnswerIndex = answerIndex
        showAnswerFeedback = false // Reset feedback for new selections
    }

    func submitAnswer() {
        guard let selectedIndex = selectedAnswerIndex, let question = currentQuestion else { return }

        if selectedIndex == question.correctAnswerIndex {
            score += 1
            feedbackMessage = "Correct!"
            feedbackColor = .green
            userProgressService.earnBadge(.init(id: "quizScorePlusOne", name: "Quiz Star", description: "Got a question right!", imageName: "star")) // Example badge
        } else {
            feedbackMessage = "Incorrect. The correct answer was: \(question.options[question.correctAnswerIndex])"
            feedbackColor = .red
        }

        showAnswerFeedback = true
    }

    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil // Reset selection for next question
            showAnswerFeedback = false
        } else {
            // Last question submitted
            quizCompleted = true
            userProgressService.completeQuiz(for: exhibitId)
            // --- Badge Awarding Logic ---
            // Example: If quiz completion for a specific exhibit earns a specific badge
            if exhibitId == "fossilGallery" {
                // Check if the user already has this badge before awarding
                if let fossilBadge = badgeDataService.loadBadges().first(where: { $0.id == "fossilExplorer" }) { // Assuming "fossilExplorer" is the ID in badges.json
                    userProgressService.earnBadge(fossilBadge)
                }
            } else if exhibitId == "mammalGallery" {
                // Award another badge if applicable
                    if let wildlifeBadge = badgeDataService.loadBadges().first(where: { $0.id == "wildlifeEnthusiast" }) {
                            userProgressService.earnBadge(wildlifeBadge)
                        }
                    }
                    // ... more exhibit-specific awards ...

                    // Award a high score badge if conditions met
                    if score >= questions.count / 2 {
                        if let aceBadge = badgeDataService.loadBadges().first(where: { $0.id == "masterNaturalist" }) { // Example: high score might lead to Master Naturalist
                            userProgressService.earnBadge(aceBadge)
                    }
                }
                    // --- End Badge Awarding Logic ---

                userProgressService.saveProgress()
            }
        }
}
