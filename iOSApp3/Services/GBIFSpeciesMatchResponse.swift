//
//  GBIFSpeciesMatchResponse.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

final class GBIFService {
    func fetchSpeciesMatch(for name: String) async throws -> GBIFData {
        guard var urlComponents = URLComponents(string: "https://api.gbif.org/v1/species/match") else {
            throw GBIFServiceError.invalidUrl
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]

        guard let url = urlComponents.url else {
            throw GBIFServiceError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("NatureExplorer/1.0 educational iOS app", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw GBIFServiceError.badResponse
        }

        let decodedResponse = try JSONDecoder().decode(GBIFSpeciesMatchResponse.self, from: data)

        return decodedResponse.toGBIFData()
    }
}

enum GBIFServiceError: Error {
    case invalidUrl
    case badResponse
}
