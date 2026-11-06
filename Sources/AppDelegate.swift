import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        MainMenu.install()
        Task { @MainActor in
            await StickyWindowManager.shared.start()
        }
    }

    /// Whenever Reforged becomes the active app, every card rises to the top.
    func applicationDidBecomeActive(_ notification: Notification) {
        StickyWindowManager.shared.bringAllToFront()
    }

    /// Called when the Dock icon is clicked while the app is already running.
    /// We show every note (including hidden/minimized ones) and skip the
    /// default behavior, which would only restore a single window.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        StickyWindowManager.shared.showAll()
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
