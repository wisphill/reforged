import Foundation

/// One English word shown on a sticky window.
///
/// This is intentionally independent of where the data comes from, so an
/// Obsidian `.md` parser can later produce the same type.
struct WordNote: Identifiable, Hashable {
    let id: String
    let word: String
    var phonetic: String?
    var partOfSpeech: String?
    var definition: String
    var example: String?
}
