//
//  GalleryDetailView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-29.
//

import SwiftUI

/// Gallery screen showing curated records for empty query
/// and live GBIF global records for non-empty query.
struct GalleryDetailView: View {
    
    /// Active gallery context selected from the museum map.
    let gallery: MuseumGallery

    // MARK: - View State
    /// User-entered query text.
    @State private var searchQuery: String = ""
    /// Rendered specimen cards for current mode (curated/global).
    @State private var specimens: [DisplayItem] = []
    /// Current specimen selected for detail sheet presentation.
    @State private var selectedSpecimen: DisplayItem?

    /// Global loading state while remote search is in progress.
    @State private var isLoading: Bool = false
    /// User-facing search/network error.
    @State private var errorMessage: String?
    /// Cancellable task for debounced global search requests.
    @State private var searchTask: Task<Void, Never>?

    /// Grid layout for two-column specimen cards.
    private let gridLayout: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // General Museum Gallery Header
            VStack(alignment: .leading, spacing: 6) {
                Text(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "EXPLORING POPULAR MOUNTS" : "GLOBAL GBIF SEARCH ACTIVE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(gallery.color)
                    .tracking(2.0)

                Text(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? gallery.rawValue : "Cross-Gallery Results")
                    .font(.title2)
                    .bold()

                Text(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                     ? gallery.galleryDescription
                     : "Live query against GBIF global occurrence records.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))

            // Search box
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search common/scientific name or family...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch(immediate: true)
                    }

                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                        performSearch(immediate: true)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .padding()
            .onChange(of: searchQuery) { _ in
                performSearch(immediate: false)
            }

            // Content
            if isLoading {
                Spacer()
                ProgressView("Searching live GBIF database...")
                Spacer()
            } else if let errorMessage {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else if specimens.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary)
                    Text("No specimens match your search")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: gridLayout, spacing: 16) {
                        ForEach(specimens) { item in
                            let isGlobal = item.id.hasPrefix("gbif_occ_")
                            let currentGallery = isGlobal ? gallery : GBIFDiscoveryService.shared.resolveGalleryFromId(item.id)

                            Button(action: { selectedSpecimen = item }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    SpecimenImageView(item: item, gallery: currentGallery)

                                    Text(item.title)
                                        .font(.subheadline)
                                        .bold()
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 4)

                                    HStack {
                                        Text(isGlobal ? "GLOBAL GBIF" : currentGallery.rawValue)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(isGlobal ? Color.indigo : currentGallery.color)
                                            .cornerRadius(6)

                                        Spacer()

                                        Text(item.gbifData?.family ?? "Sourced")
                                            .font(.system(size: 8, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.bottom, 6)
                                }
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            performSearch(immediate: true)
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .sheet(item: $selectedSpecimen) { specimen in
            let hostGallery = GBIFDiscoveryService.shared.resolveGalleryFromId(specimen.id)
            MuseumSpecimenDetailView(item: specimen, themeColor: hostGallery.color)
        }
    }

    /// Executes search for the current query.
    ///
    /// Behavior:
    /// - Empty query: curated records for the active gallery.
    /// - Non-empty query: live global GBIF occurrence search only.
    /// - Parameter immediate: If `false`, applies debounce delay.
    @MainActor
    private func performSearch(immediate: Bool) {
        searchTask?.cancel()

        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty query => only this gallery's curated set
        guard !q.isEmpty else {
            isLoading = false
            errorMessage = nil
            specimens = GBIFDiscoveryService.shared.fetchGallerySpecimens(gallery: gallery, query: "")
            print("📚 CURATED gallery=\(gallery.rawValue) count=\(specimens.count)")
            return
        }

        isLoading = true
        errorMessage = nil
        specimens = []

        searchTask = Task {
            if !immediate {
                try? await Task.sleep(nanoseconds: 350_000_000)
                if Task.isCancelled { return }
            }

            do {
                let results = try await GBIFDiscoveryService.shared.searchGBIFGlobal(query: q, limit: 80, offset: 0)
                if Task.isCancelled { return }

                // Hard guard: only true global occurrence IDs
                let globalOnly = results.filter { $0.id.hasPrefix("gbif_occ_") }

                await MainActor.run {
                    specimens = globalOnly
                    isLoading = false
                    errorMessage = globalOnly.isEmpty ? "No global GBIF matches for '\(q)'." : nil
                    print("🌍 GLOBAL query='\(q)' raw=\(results.count) shown=\(globalOnly.count)")
                }
            } catch is CancellationError {
                // expected while typing
            } catch {
                if Task.isCancelled { return }
                await MainActor.run {
                    specimens = []
                    isLoading = false
                    errorMessage = "GBIF search failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
