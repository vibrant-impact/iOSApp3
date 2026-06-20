//
//  AudioGuideService.swift
//  iOSApp3
//
//  Created by stephanie otteson on 2026-06-18.
//

import Foundation
import AVFoundation

// Uses Apple’s built-in text-to-speech
// Reads the display audio according to the selected age-related style
final class AudioGuideService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
    }

    func speak(display: DisplayItem, ageGroup: AgeGroup) {
        stop()

        let script = makeScript(display: display, ageGroup: ageGroup)
        let utterance = AVSpeechUtterance(string: script)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-CA")
        utterance.rate = speechRate(for: ageGroup)
        utterance.pitchMultiplier = pitch(for: ageGroup)

        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func makeScript(display: DisplayItem, ageGroup: AgeGroup) -> String {
        let scienceIntro = makeScienceIntro(for: display)

        switch ageGroup {
        case .child:
            return """
            Let's explore the \(display.title)! \(display.shortDescription)
            \(scienceIntro)
            Here's a cool fact: \(display.funFacts.isEmpty ? "Nature is full of surprises!" : display.funFacts.randomElement()!)
            """

        case .teen:
            return """
            This exhibit focuses on the \(display.title). \(display.detailedDescription)
            \(scienceIntro)
            Did you know? \(display.funFacts.isEmpty ? "It plays a key role in our ecosystem." : display.funFacts.randomElement()!)
            """

        case .adult:
            let facts = display.funFacts.joined(separator: " ")
            return """
            Welcome to the exhibit on the \(display.title). \(display.detailedDescription)
            \(scienceIntro)
            Analysis notes: \(facts)
            """
        }
    }

    private func makeScienceIntro(for display: DisplayItem) -> String {
        guard let gbifData = display.gbifData else { return "" }
        var parts: [String] = []

        if let canonicalName = gbifData.canonicalName {
            parts.append("Its scientific classification is \(canonicalName).")
        }
        if let taxonomicClass = gbifData.taxonomicClass {
            parts.append("It is classified inside the class \(taxonomicClass).")
        }
        if let family = gbifData.family {
            parts.append("It belongs to the \(family) biological family.")
        }

        return parts.joined(separator: " ")
    }

    private func speechRate(for ageGroup: AgeGroup) -> Float {
        switch ageGroup {
        case .child: return 0.42
        case .teen: return 0.48
        case .adult: return 0.50
        }
    }

    private func pitch(for ageGroup: AgeGroup) -> Float {
        switch ageGroup {
        case .child: return 1.15
        case .teen: return 1.05
        case .adult: return 1.00
        }
    }
}
