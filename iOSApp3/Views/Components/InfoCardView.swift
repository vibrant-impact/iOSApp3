//
//  InfoCardView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

// Detailed info for each display within the exhibits
struct InfoCardView: View {
    let display: DisplayItem

    var body: some View {
        HStack(spacing: 16) {
            remoteImage
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 6) {
                Text(display.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(display.shortDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var remoteImage: some View {
        AsyncImage(url: display.imageUrl) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color.green.opacity(0.15)
                    ProgressView()
                }

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                ZStack {
                    Color.green.opacity(0.15)
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                }

            @unknown default:
                ZStack {
                    Color.green.opacity(0.15)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
