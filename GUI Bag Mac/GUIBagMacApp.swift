import AppKit
import SwiftUI

@main
struct GUIBagMacApp: App {
    init() {
        BundledApplicationIcon.applyAsDockIcon()
    }

    var body: some Scene {
        WindowGroup {
            LaunchRootView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

/// Loads the same icon macOS uses for this app in Finder and the Dock.
/// `Image("AppIcon")` is not backed by the App Icon asset set like a normal imageset, so it often fails or disappears at runtime.
enum BundledApplicationIcon {
    static func nsImage() -> NSImage? {
        let name = NSImage.applicationIconName
        if let image = NSImage(named: name), !image.representations.isEmpty {
            return image
        }
        let path = Bundle.main.bundlePath
        guard !path.isEmpty else { return nil }
        return NSWorkspace.shared.icon(forFile: path)
    }

    static func applyAsDockIcon() {
        guard let image = nsImage() else { return }
        NSApplication.shared.applicationIconImage = image
    }
}
