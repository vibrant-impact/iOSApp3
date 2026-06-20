//
//  ExhibitDetailView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

// Shows all the available displays within a gallery
struct ExhibitDetailView: View {
    let exhibit: Exhibit
    let ageGroup: AgeGroup

    @StateObject private var viewModel: ExhibitDetailViewModel
    @State private var selectedDisplay: DisplayItem?
    @State private var audioGuideService = AudioGuideService()
    let userProgressService: UserProgressService

    @State private var showingQuizSheet = false

    init(exhibit: Exhibit, ageGroup: AgeGroup, userProgressService: UserProgressService) {
        self.exhibit = exhibit
        self.ageGroup = ageGroup
        self.userProgressService = userProgressService
        _viewModel = StateObject(wrappedValue: ExhibitDetailViewModel(exhibit: exhibit, userProgressService: userProgressService))
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                headerSection
                
                Text(exhibit.summary)
                    .padding(.horizontal)
                
                // 1. Only show the Quiz Button dynamically
                if !userProgressService.progress.hasCompletedQuiz(for: exhibit.id) { // Only show if quiz is not completed
                    Button {
                        // Present the QuizView as a modal sheet
                        // Note: We'll need to pass exhibitId, exhibitName, and UserProgressService
                        showingQuizSheet = true
                    } label: {
                        Label("Take Quiz", systemImage: "questionmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                Text(exhibit.summary)
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("Displays")
                    .font(.title2)
                    .fontWeight(.bold)

                if viewModel.isLoading {
                    ProgressView("Loading displays from APIs...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Could not load displays",
                        systemImage: "wifi.exclamationmark",
                        description: Text(errorMessage)
                    )
                } else {
                    ForEach(viewModel.displayItems) { display in
                        Button {
                            selectedDisplay = display
                        } label: {
                            InfoCardView(display: display)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingQuizSheet) {
            QuizView(
                exhibitId: exhibit.id,
                exhibitName: exhibit.name,
                userProgressService: userProgressService
            )
        }
        
        .navigationTitle(exhibit.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDisplayItems()
        }
        .sheet(item: $selectedDisplay) { display in
            displayDetailSheet(display: display)
        }
        .onDisappear {
            audioGuideService.stop()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exhibit.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Floor \(exhibit.floor)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(exhibit.theme)
                .font(.headline)
                .foregroundStyle(.green)
        }
    }

    private func displayDetailSheet(display: DisplayItem) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    largeRemoteImage(for: display)

                    Text(display.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(descriptionText(for: display))
                        .font(.body)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Facts")
                            .font(.title2)
                            .fontWeight(.bold)

                        ForEach(display.funFacts, id: \.self) { fact in
                            Label(fact, systemImage: "sparkles")
                                .font(.body)
                        }
                    }
                    
                    taxonomySection(for: display)

                    HStack {
                        Button {
                            audioGuideService.speak(
                                display: display,
                                ageGroup: ageGroup
                            )
                        } label: {
                            Label("Play Audio Guide", systemImage: "speaker.wave.2.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            audioGuideService.stop()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                        }
                        .buttonStyle(.bordered)
                    }

                    attributionSection(for: display)
                }
                .padding()
            }
            .navigationTitle(display.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func largeRemoteImage(for display: DisplayItem) -> some View {
        AsyncImage(url: display.imageUrl) { phase in
            switch phase {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.green.opacity(0.15))

                    ProgressView()
                }
                .frame(height: 240)

            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18))

            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.green.opacity(0.15))

                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)

                        Text("Image unavailable")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 240)

            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func taxonomySection(for display: DisplayItem) -> some View {
        Group {
            if let gbifData = display.gbifData, gbifData.hasUsefulData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Scientific Classification")
                        .font(.title2)
                        .fontWeight(.bold)

                    VStack(spacing: 0) {
                        taxonomyRow(label: "Scientific Name", value: gbifData.scientificName)
                        taxonomyRow(label: "Canonical Name", value: gbifData.canonicalName)
                        taxonomyRow(label: "Rank", value: gbifData.rank)
                        taxonomyRow(label: "Kingdom", value: gbifData.kingdom)
                        taxonomyRow(label: "Phylum", value: gbifData.phylum)
                        taxonomyRow(label: "Class", value: gbifData.taxonomicClass)
                        taxonomyRow(label: "Order", value: gbifData.order)
                        taxonomyRow(label: "Family", value: gbifData.family)
                        taxonomyRow(label: "Genus", value: gbifData.genus)
                    }
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.green.opacity(0.25), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func taxonomyRow(label: String, value: String?) -> some View {
        Group {
            if let value, !value.isEmpty {
                HStack(alignment: .top) {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 130, alignment: .leading)

                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()
                    .padding(.leading)
            }
        }
    }

    private func observationRow(label: String, value: String?) -> some View {
        Group {
            if let value, !value.isEmpty {
                HStack(alignment: .top) {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 130, alignment: .leading)

                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func attributionSection(for display: DisplayItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(display.attributionText)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let sourceUrl = display.sourceUrl {
                Link("View Wikipedia Source", destination: sourceUrl)
                    .font(.caption)
            }

            if let usageKey = display.gbifData?.usageKey,
               let gbifUrl = URL(string: "https://www.gbif.org/species/\(usageKey)") {
                Link("View GBIF Species Page", destination: gbifUrl)
                    .font(.caption)
            }

        }
        .padding(.top)
    }

    private func descriptionText(for display: DisplayItem) -> String {
        switch ageGroup {
        case .child:
            return display.shortDescription
        case .teen, .adult:
            return display.detailedDescription
        }
    }
}
