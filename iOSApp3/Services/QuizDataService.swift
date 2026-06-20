//
//  QuizDataService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation

final class QuizDataService {
    func loadQuizQuestions() async throws -> [QuizQuestion] {
        guard let url = Bundle.main.url(forResource: "quizQuestions", withExtension: "json") else {
            throw QuizDataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let questions = try JSONDecoder().decode([QuizQuestion].self, from: data)
        return questions
    }
}

enum QuizDataError: Error {
    case fileNotFound
}
