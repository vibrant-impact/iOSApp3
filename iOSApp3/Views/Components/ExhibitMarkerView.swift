//
//  ExhibitMarkerView.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

// Museum map markers
struct ExhibitMarkerView: View {
    let exhibit: Exhibit

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(.green)
                .clipShape(Circle())
                .shadow(radius: 4)

            Text(exhibit.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(width: 90)
        }
    }

    private var iconName: String {
        let theme = exhibit.theme.lowercased()

        if theme.contains("dinosaur") || theme.contains("fossil") {
            return "fossil.shell.fill"
        } else if theme.contains("bird") {
            return "bird.fill"
        } else if theme.contains("mammal") {
            return "pawprint.fill"
        } else {
            return "leaf.fill"
        }
    }
}
