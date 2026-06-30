//
//  MuseumMapView.swift
//  iOSApp3
//
//  Main landing screen displaying the museum floor map,
//  floor selector, and tappable gallery pins.
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

/// Root map-based navigation view for browsing galleries by floor.
struct MuseumMapView: View {
    /// Current selected floor level for map image and pin filtering.
    @State private var selectedLevel: Int = 2

    /// Asset name for top welcome hero banner.
    private let welcomeAssetName = "welcome_banner"
    /// Background tint used across the map screen.
    private let museumGreen = Color(red: 0.88, green: 0.95, blue: 0.88)

    var body: some View {
        NavigationStack {
            ZStack {
                museumGreen.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Extra room so top content is never crowded by Dynamic Island/status area
                    Color.clear
                        .frame(height: 14)

                    // MARK: - Welcome Banner
                    ZStack {
                        Image(welcomeAssetName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 400)
                            .clipped()

                        VStack(spacing: 4) {
                            Text("WELCOME TO THE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                                .tracking(2)

                            Text("Canadian Museum of Nature")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        }
                    }
                    .frame(height: 400)
                    .padding(.horizontal, 8)

                    // MARK: - Floor Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXPLORE FLOORS")
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(.black)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        Picker("Museum Floor Level", selection: $selectedLevel) {
                            Text("Level 0").tag(0)
                            Text("Level 1").tag(1)
                            Text("Level 2").tag(2)
                            Text("Level 3").tag(3)
                            Text("Level 4").tag(4)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .background(Color(.green).opacity(0.2))

                    // MARK: - Floor Map + Pins (tighter, no extra white top/bottom)
                    ZStack {
                        Image("floor_\(selectedLevel)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
                            .cornerRadius(12)

                        GeometryReader { geo in
                            let w = geo.size.width
                            let h = geo.size.height

                            ForEach(MuseumGallery.allCases.filter { $0.floor == selectedLevel }) { gallery in
                                NavigationLink(destination: GalleryDetailView(gallery: gallery)) {
                                    GalleryPinNode(gallery: gallery)
                                }
                                .position(resolveCoordinates(for: gallery, w: w, h: h))
                            }
                        }
                        .frame(height: 230)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                    // MARK: - Footer Tip
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.green)

                        Text("Choose a floor, then tap a gallery marker to view the featured specimens and search museum exhibits.")
                            .font(.caption)
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.green).opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Gallery Coordinates Per Floor Map
    /// Returns normalized pin coordinates for each gallery
    /// relative to the active floor map dimensions.
    private func resolveCoordinates(for gallery: MuseumGallery, w: CGFloat, h: CGFloat) -> CGPoint {
        let px: CGFloat
        let py: CGFloat

        switch gallery {
        case .bugs:
            px = 0.75; py = 0.25
        case .fossils:
            px = 0.675; py = 0.53
        case .water:
            px = 0.325; py = 0.56
        case .mammals:
            px = 0.675; py = 0.56
        case .earth:
            px = 0.245; py = 0.585
        case .birds:
            px = 0.808; py = 0.565
        case .arctic:
            px = 0.195; py = 0.575
        }

        return CGPoint(x: w * px, y: h * py)
    }
}

/// Small reusable map pin node for a gallery marker.
struct GalleryPinNode: View {
    let gallery: MuseumGallery

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(gallery.color)
                    .frame(width: 32, height: 32)
                    .shadow(radius: 6)

                Image(systemName: gallery.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            }

            Text(gallery.rawValue)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(6)
                .shadow(radius: 2)
        }
    }
}
