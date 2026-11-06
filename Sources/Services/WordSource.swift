import Foundation

/// Anything that can provide words to display.
///
/// Today: `MockWordSource`. Later: an `ObsidianWordSource` that reads `.md`
/// files from a vault and conforms to this same protocol.
protocol WordSource {
    func loadWords() async throws -> [WordNote]
}

struct MockWordSource: WordSource {
    func loadWords() async throws -> [WordNote] {
        [
            WordNote(
                id: "ephemeral",
                word: "ephemeral",
                phonetic: "/ɪˈfem(ə)rəl/",
                partOfSpeech: "adjective",
                definition: "Lasting for a very short time.",
                example: "Fashions are ephemeral; they change with every season."
            ),
            WordNote(
                id: "serendipity",
                word: "serendipity",
                phonetic: "/ˌserənˈdipədē/",
                partOfSpeech: "noun",
                definition: "The occurrence of happy or beneficial events by chance.",
                example: "Finding that bookshop was pure serendipity."
            ),
            WordNote(
                id: "ubiquitous",
                word: "ubiquitous",
                phonetic: "/yo͞oˈbikwədəs/",
                partOfSpeech: "adjective",
                definition: "Present, appearing, or found everywhere.",
                example: "Smartphones have become ubiquitous."
            ),
            WordNote(
                id: "resilient",
                word: "resilient",
                phonetic: "/rɪˈzɪljənt/",
                partOfSpeech: "adjective",
                definition: "Able to recover quickly from difficulties; tough.",
                example: "Children are often more resilient than adults expect."
            ),
            WordNote(
                id: "meticulous",
                word: "meticulous",
                phonetic: "/məˈtikyələs/",
                partOfSpeech: "adjective",
                definition: "Showing great attention to detail; very careful and precise.",
                example: "She kept meticulous records of every experiment."
            ),
            WordNote(
                id: "candid",
                word: "candid",
                phonetic: "/ˈkandəd/",
                partOfSpeech: "adjective",
                definition: "Truthful and straightforward; frank.",
                example: "I appreciate your candid feedback."
            ),
        ]
    }
}
