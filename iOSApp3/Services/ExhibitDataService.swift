//
//  ExhibitDataService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation

final class ExhibitDataService {
    func loadExhibits() async throws -> [Exhibit] {
        guard let url = Bundle.main.url(forResource: "exhibitSeeds", withExtension: "json") else {
            throw ExhibitDataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let exhibits = try JSONDecoder().decode([Exhibit].self, from: data)

        return exhibits
    }
}

enum ExhibitDataError: Error {
    case fileNotFound
}
