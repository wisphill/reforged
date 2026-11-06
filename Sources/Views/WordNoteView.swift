import AppKit
import SwiftUI

/// Pastel sticky-note colors.
enum NoteColor: CaseIterable {
    case yellow, pink, blue, green, purple, orange

    var nsColor: NSColor {
        switch self {
        case .yellow: return NSColor(red: 1.00, green: 0.95, blue: 0.62, alpha: 1)
        case .pink:   return NSColor(red: 1.00, green: 0.80, blue: 0.86, alpha: 1)
        case .blue:   return NSColor(red: 0.74, green: 0.88, blue: 1.00, alpha: 1)
        case .green:  return NSColor(red: 0.78, green: 0.94, blue: 0.76, alpha: 1)
        case .purple: return NSColor(red: 0.86, green: 0.80, blue: 1.00, alpha: 1)
        case .orange: return NSColor(red: 1.00, green: 0.86, blue: 0.68, alpha: 1)
        }
    }

    var color: Color { Color(nsColor: nsColor) }

    static func color(at index: Int) -> NoteColor {
        allCases[index % allCases.count]
    }
}

struct WordNoteView: View {
    let note: WordNote
    let noteColor: NoteColor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(note.word)
                        .font(.system(size: 26, weight: .bold, design: .serif))

                    Button {
                        Pronouncer.shared.speak(note.word)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 15))
                            .padding(4)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .opacity(0.65)
                    .help("Hear pronunciation")
                }

                if note.phonetic != nil || note.partOfSpeech != nil {
                    HStack(spacing: 8) {
                        if let phonetic = note.phonetic {
                            Text(phonetic)
                        }
                        if let pos = note.partOfSpeech {
                            Text(pos).italic()
                        }
                    }
                    .font(.system(size: 12))
                    .opacity(0.6)
                }

                Divider().opacity(0.4)

                Text(note.definition)
                    .font(.system(size: 14))

                if let example = note.example {
                    Text("“\(example)”")
                        .font(.system(size: 13, design: .serif))
                        .italic()
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.top, 30) // room for the transparent title bar
            .padding(.bottom, 14)
        }
        .foregroundColor(.black.opacity(0.85))
        .background(noteColor.color.ignoresSafeArea())
    }
}
