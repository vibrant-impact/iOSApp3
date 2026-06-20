//
//  BadgesView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import SwiftUI

struct BadgesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BadgesViewModel
    private let userProgressService: UserProgressService

    init(userProgressService: UserProgressService) {
        self.userProgressService = userProgressService
        _viewModel = StateObject(wrappedValue: BadgesViewModel(userProgressService: userProgressService))
    }

    var body: some View {
        NavigationStack {
            contentBody
                .navigationTitle("Your Badges")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close", action: dismiss.callAsFunction)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            userProgressService.resetProgress()
                            Task { await viewModel.loadBadges() }
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise.circle")
                        }
                    }
                }
                .task {
                    await viewModel.loadBadges()
                }
        }
    }
}

private extension BadgesView {
    @ViewBuilder
    var contentBody: some View {
        if !viewModel.hasLoadedBadgeDefinitions {
            loadingState
        } else if viewModel.availableBadges.isEmpty {
            emptyState
        } else {
            badgesGrid
        }
    }

    var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading badge definitions…")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "seal")
                .font(.system(size: 48))
                .foregroundColor(Color(.tertiaryLabel))
            Text("No badges earned yet")
                .font(.headline)
            Text("Finish quizzes to unlock your first badge.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    var badgesGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(viewModel.availableBadges, id: \.id) { badge in
                    badgeView(for: badge)
                }
            }
            .padding()
        }
    }

    func badgeView(for badge: Badge) -> some View {
        VStack(spacing: 8) {
            Image(badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                )

            Text(badge.name)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(badge.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
