//
//  MuseumMapView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

// Creates a simple clickable map
// Main museum map for museum navigation
struct MuseumMapView: View {
    let ageGroup: AgeGroup

    @StateObject private var viewModel = MuseumMapViewModel()
    @StateObject private var userProgressService = UserProgressService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Loading exhibits...")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    mapContent
                }
            }
            .navigationTitle("Museum Map")
            .task {
                await viewModel.loadExhibits()
            }
        }
    }

    private var mapContent: some View {
        VStack(spacing: 16) {
            Text("Tap an exhibit marker to explore.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink {
                BadgesView(userProgressService: self.userProgressService) // Pass the service
            } label: {
                Label("Your Badges", systemImage: "gift.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.25), .blue.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(.green.opacity(0.5), lineWidth: 3)
                        )

                    museumPathOverlay

                    ForEach(viewModel.exhibits) { exhibit in
                        NavigationLink {
                            ExhibitDetailView(
                                exhibit: exhibit,
                                ageGroup: ageGroup,
                                userProgressService: self.userProgressService // Pass the service here!
                            )
                        } label: {
                            ExhibitMarkerView(exhibit: exhibit)
                        }
                        .position(
                            x: geometry.size.width * exhibit.mapX,
                            y: geometry.size.height * exhibit.mapY
                        )
                    }
                }
            }
            .frame(height: 500)
            .padding()

            Spacer()
        }
    }

    private var museumPathOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.4))
                .frame(width: 240, height: 60)
                .offset(y: -80)

            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.4))
                .frame(width: 80, height: 260)

            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.4))
                .frame(width: 260, height: 60)
                .offset(y: 110)
        }
    }
}
