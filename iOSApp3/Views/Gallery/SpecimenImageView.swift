//
//  SpecimenImageView.swift
//  iOSApp3
//
//  Unified specimen image component with multi-source fallback strategy:
//  1) local asset
//  2) curated URL / GBIF URL
//  3) Wikipedia URL
//  4) themed placeholder
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI
import UIKit
import Combine

/// Card/detail image renderer with asynchronous multi-source loading.
struct SpecimenImageView: View {
    let item: DisplayItem
    let gallery: MuseumGallery
    /// Target view height for card/list/detail reuse.
    var height: CGFloat = 110

    /// Internal loader object handling sequential URL probing.
    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        ZStack {
            if let local = loadLocalImage() {
                Image(uiImage: local).resizable().scaledToFill()
            } else if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(gallery.color.opacity(0.10))
            } else if loader.isLoading {
                ZStack {
                    gallery.color.opacity(0.12)
                    ProgressView()
                }
            } else {
                fallbackPlaceholder
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(gallery.color.opacity(0.12))
        .clipped()
        .cornerRadius(8)
        .task(id: item.id) {
            var urls: [URL] = []

            // 1) Curated URL if you keep any good ones
            if let curated = item.imageURL {
                urls.append(curated)
            }

            // 2) GBIF media (primary API showcase)
            if let gbifURL = await GBIFImageService.shared.imageURL(for: item) {
                urls.append(gbifURL)
            }

            // 3) Wikipedia fallback for fossils/earth/etc.
            let query = SpecimenImageQueryResolver.query(for: item)
            if let wikiURL = await WikipediaImageService.shared.imageURL(for: query) {
                urls.append(wikiURL)
            }

            await loader.load(firstWorkingFrom: urls, id: item.id)
        }

    }

    /// Attempts to load bundled local image variants using ID/title naming.
    private func loadLocalImage() -> UIImage? {
        let keys = [item.id, item.title, item.title.replacingOccurrences(of: " ", with: "_")]
        for key in keys {
            if let img = UIImage(named: key) { return img }
        }
        return nil
    }

    /// Themed placeholder shown when all sources fail.
    private var fallbackPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [gallery.color.opacity(0.75), gallery.color.opacity(0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 6) {
                Image(systemName: gallery.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text(item.gbifData?.family ?? "Specimen")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
        }
    }
}

/// Main-thread image loader that tries candidate URLs in order
/// and publishes the first successfully decoded `UIImage`.
@MainActor
final class RemoteImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    /// Iterates through candidate URLs and keeps the first valid image response.
    /// - Parameters:
    ///   - urls: Ordered URL candidates from preferred to fallback sources.
    ///   - id: Specimen ID used in debug logging.
    func load(firstWorkingFrom urls: [URL], id: String) async {
        image = nil
        guard !urls.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        for url in urls {
            do {
                var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
                req.setValue("Mozilla/5.0 (iOSApp3)", forHTTPHeaderField: "User-Agent")

                let (data, response) = try await URLSession.shared.data(for: req)
                if let http = response as? HTTPURLResponse {
                    print("🧪 [Image] id=\(id) status=\(http.statusCode) url=\(url.absoluteString)")
                    guard (200...299).contains(http.statusCode) else { continue }
                }

                if let uiImage = UIImage(data: data) {
                    image = uiImage
                    return
                }
            } catch {
                print("🧪 [Image] id=\(id) error=\(error.localizedDescription) url=\(url.absoluteString)")
            }
        }

        print("🧪 [Image] id=\(id) all sources failed")
    }
}
