//
//  AgeSelectionView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

// Welcome screen with age-related audio guide style picker
struct AgeSelectionView: View {
    @State private var selectedAgeGroup: AgeGroup = .teen

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)

                Text("Nature Explorer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Explore the Canadian Museum of Nature through an interactive virtual map.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose audio guide style")
                        .font(.headline)

                    Picker("Age Group", selection: $selectedAgeGroup) {
                        ForEach(AgeGroup.allCases) { ageGroup in
                            Text(ageGroup.rawValue).tag(ageGroup)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(selectedAgeGroup.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()

                NavigationLink {
                    MuseumMapView(ageGroup: selectedAgeGroup)
                } label: {
                    Text("Start Exploring")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Welcome")
        }
    }
}
