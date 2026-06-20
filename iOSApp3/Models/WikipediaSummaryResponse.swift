//
//  WikipediaSummaryResponse.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

struct WikipediaSummaryResponse: Decodable {
    let title: String
    let description: String?
    let extract: String?
    let thumbnail: WikipediaThumbnail?
    let contentUrls: WikipediaContentUrls?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case extract
        case thumbnail
        case contentUrls = "content_urls"
    }
}

struct WikipediaThumbnail: Decodable {
    let source: String
}

struct WikipediaContentUrls: Decodable {
    let desktop: WikipediaDesktopUrls?
}

struct WikipediaDesktopUrls: Decodable {
    let page: String?
}
