//
//  QuizQuestion.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation

struct QuizQuestion: Identifiable, Decodable {
    let id: String
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int // Index in the options array
    let exhibitId: String // To link questions to exhibits
}
