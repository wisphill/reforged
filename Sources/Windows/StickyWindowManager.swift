import AppKit
import SwiftUI

/// Deals out one new word card at a time at a random spot on screen.
/// Cards may overlap and pile up without limit until the user closes them.
@MainActor
final class StickyWindowManager: NSObject, NSWindowDelegate {
    static let shared = StickyWindowManager()

    /// Seconds between new cards.
    static let dealInterval: TimeInterval = 20

    private struct Card {
        let note: WordNote
        let window: NSWindow
    }

    private var allWords: [WordNote] = []
    private var upcoming: [WordNote] = []   // shuffled queue of words still to deal
    private var cards: [Card] = []          // oldest first
    private var timer: Timer?

    private let noteSize = NSSize(width: 260, height: 190)

    // MARK: - Lifecycle

    func start(with source: WordSource = MockWordSource()) async {
        do {
            allWords = try await source.loadWords()
        } catch {
            NSLog("Failed to load words: \(error)")
            return
        }
        dealNextCard()
        startTimer()
    }

    /// Dock click: bring every card on screen to the front. If the desk is
    /// empty (everything was dismissed), deal a fresh card right away.
    func showAll() {
        NSApp.unhide(nil)
        if cards.isEmpty { dealNextCard() }
        bringAllToFront()
        cards.last?.window.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Raises every card above other apps' windows. Called whenever the user
    /// activates Reforged (Dock click, Cmd+Tab, clicking a card).
    func bringAllToFront() {
        let keyWindow = NSApp.keyWindow
        for card in cards {
            if card.window.isMiniaturized { card.window.deminiaturize(nil) }
            card.window.orderFrontRegardless()
        }
        keyWindow?.orderFrontRegardless() // keep the card the user clicked on top
    }

    // MARK: - Dealing cards

    private func startTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: Self.dealInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.dealNextCard() }
        }
        // .common keeps it firing while menus are open or a window is being dragged.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// Adds one new card at a random position without stealing focus.
    func dealNextCard() {
        guard let note = nextWord() else { return }

        let colorIndex = allWords.firstIndex(of: note) ?? 0
        let window = makeWindow(for: note, color: NoteColor.color(at: colorIndex))
        window.setFrame(randomFrame(size: noteSize), display: false)
        cards.append(Card(note: note, window: window))

        window.alphaValue = 0
        if NSApp.isActive {
            window.orderFrontRegardless()
        } else if !NSApp.isHidden {
            // Another app is in front: show the card behind everything instead
            // of popping over what the user is doing. It rises when they
            // activate Reforged (see bringAllToFront).
            window.orderBack(nil)
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            window.animator().alphaValue = 1
        }
    }

    /// Next word from a shuffled queue; reshuffles once every word has been
    /// dealt, so words repeat (as new cards) after a full round.
    private func nextWord() -> WordNote? {
        if upcoming.isEmpty { upcoming = allWords.shuffled() }
        return upcoming.popLast()
    }

    private func retire(_ card: Card) {
        cards.removeAll { $0.window === card.window }
        let window = card.window
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            window.animator().alphaValue = 0
        }, completionHandler: {
            window.orderOut(nil)
            window.delegate = nil
        })
    }

    private func randomFrame(size: NSSize) -> NSRect {
        let area = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
        let maxX = max(area.minX, area.maxX - size.width)
        let maxY = max(area.minY, area.maxY - size.height)
        let origin = NSPoint(
            x: CGFloat.random(in: area.minX...maxX),
            y: CGFloat.random(in: area.minY...maxY)
        )
        return NSRect(origin: origin, size: size)
    }

    // MARK: - Window creation

    private func makeWindow(for note: WordNote, color: NoteColor) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: noteSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = note.word
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.backgroundColor = color.nsColor
        window.appearance = NSAppearance(named: .aqua) // pastel notes need dark text
        window.minSize = NSSize(width: 200, height: 120)
        window.delegate = self
        window.contentView = NSHostingView(rootView: WordNoteView(note: note, noteColor: color))
        return window
    }

    // MARK: - NSWindowDelegate

    /// Closing a card dismisses it; the next one arrives on the timer.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if let card = cards.first(where: { $0.window === sender }) {
            retire(card)
        }
        return false
    }
}
