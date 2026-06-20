//
//  QuizView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: QuizViewModel
    // Injecting UserProgressService is crucial here
    let userProgressService: UserProgressService
    private let exhibitName: String // To display in the header

    init(exhibitId: String, exhibitName: String, userProgressService: UserProgressService) {
        self.exhibitName = exhibitName
        self.userProgressService = userProgressService
        _viewModel = StateObject(wrappedValue: QuizViewModel(exhibitId: exhibitId, userProgressService: userProgressService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.quizCompleted {
                    quizCompletionView
                } else if viewModel.questions.isEmpty && !viewModel.quizCompleted {
                    ContentUnavailableView("No Quiz Available", systemImage: "questionmark.diamond", description: Text("There are no quiz questions for this exhibit yet."))
                        .task {
                            await viewModel.loadQuestions() // Try to load even if empty, for userProgress check
                        }
                } else if viewModel.questions.isEmpty && viewModel.quizCompleted {
                    quizCompletionView // Display completion if already finished
                } else if viewModel.currentQuestion != nil {
                    quizInProgressView
                } else {
                    ProgressView("Loading Quiz...")
                        .task {
                            await viewModel.loadQuestions()
                        }
                }
            }
            .navigationTitle(exhibitName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var quizInProgressView: some View {
        VStack(spacing: 20) {
            questionProgressView
            questionView
            optionsView
            submitButton
            feedbackView
            Spacer()
        }
        .padding()
    }

    private var questionProgressView: some View {
        ProgressView(
            "Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)",
            value: Double(viewModel.currentQuestionIndex + 1),
            total: Double(viewModel.questions.count)
        )
        .tint(.green)
    }

    private var questionView: some View {
        Text(viewModel.currentQuestion?.questionText ?? "Loading question...")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
    }

    private var optionsView: some View {
        VStack(spacing: 12) {
            ForEach(0 ..< (viewModel.currentQuestion?.options.count ?? 0), id: \.self) { index in
                Button {
                    viewModel.selectAnswer(index)
                } label: {
                    Text(viewModel.currentQuestion?.options[index] ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.selectedAnswerIndex == index ? .green : .gray, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.showAnswerFeedback) // Disable buttons once answer is submitted
            }
        }
    }

    private var submitButton: some View {
        Button {
            if viewModel.showAnswerFeedback {
                viewModel.nextQuestion()
            } else {
                viewModel.submitAnswer()
            }
        } label: {
            Text(viewModel.showAnswerFeedback ? "Next Question" : "Submit Answer")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.selectedAnswerIndex != nil ? .green : .gray.opacity(0.5))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.selectedAnswerIndex == nil && !viewModel.showAnswerFeedback)
    }

    private var feedbackView: some View {
        Group {
            if viewModel.showAnswerFeedback {
                Text(viewModel.feedbackMessage)
                    .font(.body)
                    .foregroundColor(viewModel.feedbackColor)
                    .padding(.horizontal)
            }
        }
    }

    private var quizCompletionView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "star.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)

            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your score: \(viewModel.score) out of \(viewModel.questions.count)")
                .font(.title2)

            // You might display earned badges here if this completion earned one
            // e.g., display earned badges from score
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
