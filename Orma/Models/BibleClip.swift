//
//  BibleVerse.swift
//  Orma
//
//  Created by Logan Norman on 8/9/25.
//

import Foundation

struct BibleClip: Identifiable, Equatable {
    let id: String
    let book: String
    let chapter: Int
    let startVerse: Int
    let endVerse: Int

    // Check if this clip overlaps with another clip in the same chapter
    func overlaps(with other: BibleClip) -> Bool {
        guard chapter == other.chapter else { return false }
        return !(endVerse < other.startVerse || startVerse > other.endVerse)
    }

    // Returns a human-readable string like "Matthew 12:8-10"
    func humanReadable() -> String {
        if startVerse == endVerse {
            return "\(book) \(chapter):\(startVerse)"
        } else {
            return "\(book) \(chapter):\(startVerse)-\(endVerse)"
        }
    }

    // Returns true if this clip contains a specific verse
    func contains(verse: Int) -> Bool {
        return verse >= startVerse && verse <= endVerse
    }
}

extension Array where Element == BibleClip {
    // Returns all clips that overlap with the given clip
    func clips(overlapping clip: BibleClip) -> [BibleClip] {
        return self.filter { $0.overlaps(with: clip) }
    }

    // Returns a human-readable string of all clips joined by commas
    func humanReadableList() -> String {
        return self.map { $0.humanReadable() }.joined(separator: ", ")
    }

    // Returns true if any clip contains the given verse
    func contains(verse: Int, inBook book: String, chapter: Int) -> Bool {
        return self.contains {
            $0.book == book && $0.chapter == chapter
                && $0.contains(verse: verse)
        }
    }
}
