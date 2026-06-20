//
//  BadgeDataService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-19.
//

import Foundation

final class BadgeDataService {
    func loadBadges() -> [Badge] {
        print("--- BadgeDataService: Attempting to load badges ---")

        guard let url = Bundle.main.url(forResource: "badges", withExtension: "json") else {
            print("🚨 ERROR: Bundle.main.url(forResource: \"badges\", withExtension: \"json\") returned nil.")
            print("   Please ensure 'badges.json' is correctly added to your project target and is included in the bundle.")
            // Add a check for target membership if this is the primary issue
            print("   Check Target Membership for 'badges.json' in Xcode's File Inspector.")
            return []
        }
        print("✅ Found badges.json at URL: \(url.path)")

        do {
            let data = try Data(contentsOf: url)
            print("✅ Successfully loaded \(data.count) bytes from badges.json")

            // Print raw string to verify content before parsing
            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- DEBUG JSON Content START ---")
                print(jsonString)
                print("--- DEBUG JSON Content END ---")
            } else {
                print("🚨 WARNING: Could not convert loaded data to a UTF-8 string for printing.")
            }
            
            let decoder = JSONDecoder()
            // If you had custom date formatting or other complex decoding needs,
            // you'd configure the decoder here. For simple structs, this is usually fine.
            
            let badges = try decoder.decode([Badge].self, from: data)
            print("✅ Successfully decoded \(badges.count) badges from JSON.")
            
            // Optional: Log details of the first decoded badge if any were found
            if !badges.isEmpty {
                print("   First badge decoded: ID=\(badges[0].id), Name='\(badges[0].name)', isEarned(default)=\(badges[0].isEarned)")
            }
            
            return badges

        } catch {
            // This catch block now handles all do-try errors more generically,
            // but we can still print detailed info.
            print("🚨 ERROR during JSON decoding or data loading:")
            
            // Try to get more specific decoding error info if available
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("   Type: DecodingError.dataCorrupted")
                    print("   Context: \(context.debugDescription)")
                    print("   codingPath: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("   Type: DecodingError.keyNotFound")
                    print("   Key: \(key.stringValue)")
                    print("   Context: \(context.debugDescription)")
                    print("   codingPath: \(context.codingPath)")
                case .valueNotFound(let value, let context):
                    print("   Type: DecodingError.valueNotFound")
                    print("   Value Type: \(value) (This is the expected Swift type if Swift could infer it)")
                    print("   Context: \(context.debugDescription)")
                    print("   codingPath: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("   Type: DecodingError.typeMismatch")
                    print("   Mismatched Swift Type: \(type)")
                    print("   Context: \(context.debugDescription)")
                    print("   codingPath: \(context.codingPath)")
                @unknown default:
                    print("   Type: Unknown DecodingError")
                    print("   Error Description: \(error.localizedDescription)")
                }
            } else {
                // Catch-all for non-DecodingError issues (e.g., Data(contentsOf:) failure)
                print("   \(error.localizedDescription)")
            }
            
            // Very important: return an empty array if any error occurs,
            // so the app doesn't crash and BadgesView can still display something (like loading).
            return []
        }
    }
}
