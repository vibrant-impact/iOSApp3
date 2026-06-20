//
//  WikipediaService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

// Fetches the text and image from Wikipedia
final class WikipediaService {
    func fetchSummary(for title: String) async throws -> WikipediaSummaryResponse {
        let formattedTitle = title.replacingOccurrences(of: " ", with: "_")

        guard let encodedTitle = formattedTitle.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encodedTitle)") else {
            throw WikipediaServiceError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("NatureExplorer/1.0 educational iOS app", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WikipediaServiceError.badResponse
        }

        let decodedResponse = try JSONDecoder().decode(WikipediaSummaryResponse.self, from: data)
        return decodedResponse
    }
}

enum WikipediaServiceError: Error {
    case invalidUrl
    case badResponse
}
