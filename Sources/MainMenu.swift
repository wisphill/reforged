import AppKit

/// Minimal programmatic main menu (there is no storyboard/nib).
enum MainMenu {
    @MainActor
    static func install() {
        let mainMenu = NSMenu()

        // App menu
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        let appName = ProcessInfo.processInfo.processName
        appMenu.addItem(withTitle: "About \(appName)",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide \(appName)",
                        action: #selector(NSApplication.hide(_:)),
                        keyEquivalent: "h")
        let hideOthers = appMenu.addItem(withTitle: "Hide Others",
                                         action: #selector(NSApplication.hideOtherApplications(_:)),
                                         keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(withTitle: "Show All",
                        action: #selector(NSApplication.unhideAllApplications(_:)),
                        keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit \(appName)",
                        action: #selector(NSApplication.terminate(_:)),
                        keyEquivalent: "q")

        // Window menu
        let windowItem = NSMenuItem()
        mainMenu.addItem(windowItem)
        let windowMenu = NSMenu(title: "Window")
        windowItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Close",
                           action: #selector(NSWindow.performClose(_:)),
                           keyEquivalent: "w")
        windowMenu.addItem(withTitle: "Minimize",
                           action: #selector(NSWindow.performMiniaturize(_:)),
                           keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom",
                           action: #selector(NSWindow.performZoom(_:)),
                           keyEquivalent: "")
        windowMenu.addItem(.separator())
        let showAll = NSMenuItem(title: "Show All Notes",
                                 action: #selector(MenuActions.showAllNotes(_:)),
                                 keyEquivalent: "0")
        showAll.keyEquivalentModifierMask = [.command, .shift]
        showAll.target = MenuActions.shared
        windowMenu.addItem(showAll)

        let next = NSMenuItem(title: "Next Word Now",
                              action: #selector(MenuActions.nextWord(_:)),
                              keyEquivalent: "n")
        next.target = MenuActions.shared
        windowMenu.addItem(next)

        NSApp.mainMenu = mainMenu
        NSApp.windowsMenu = windowMenu
    }
}

@MainActor
final class MenuActions: NSObject {
    static let shared = MenuActions()

    @objc func showAllNotes(_ sender: Any?) {
        StickyWindowManager.shared.showAll()
    }

    @objc func nextWord(_ sender: Any?) {
        StickyWindowManager.shared.dealNextCard()
    }
}
