//
//  MuseumSpecimenDetailView.swift
//  iOSApp3
//
//  Detail presentation for a selected specimen, including image,
//  descriptive text, source link, and fun facts.
//
//  Created by stephanie otteson on 2026-06-29.
//

import SwiftUI

/// Full-screen specimen detail sheet used by gallery and archive views.
struct MuseumSpecimenDetailView: View {
    /// Selected specimen record to render.
    let item: DisplayItem
    /// Accent color derived from the host gallery theme.
    let themeColor: Color
    
    /// Environment dismiss action for modal sheet closure.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Resolve host gallery from ID prefix for image theming fallback.
                    let hostGallery = GBIFDiscoveryService.shared.resolveGalleryFromId(item.id)

                    SpecimenImageView(item: item, gallery: hostGallery)
                        .frame(height: 220)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 10) {
                        // Primary specimen title.
                        Text(item.title)
                            .font(.title2)
                            .bold()

                        // External source link (GBIF occurrence page when available).
                        if let url = item.sourceUrl {
                            Link(destination: url) {
                                Label("Open GBIF Record", systemImage: "arrow.up.right")
                                    .font(.subheadline)
                                    .foregroundColor(themeColor)
                            }
                        }

                        // Long-form description.
                        Text(item.detailedDescription)
                            .foregroundColor(.secondary)

                        Divider()

                        Text("Facts")
                            .font(.headline)

                        // Key bullet facts.
                        ForEach(item.funFacts, id: \.self) { fact in
                            Text("• \(fact)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Specimen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
