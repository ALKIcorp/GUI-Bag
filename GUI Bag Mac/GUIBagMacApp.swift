import AppKit
import CoreText
import SwiftUI

@main
struct GUIBagMacApp: App {
    init() {
        AppFonts.registerAll()
        BundledApplicationIcon.applyAsDockIcon()
    }

    var body: some Scene {
        WindowGroup {
            LaunchRootView()
        }
        .defaultSize(width: 1280, height: 820)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About \(AppMetadata.displayName)") {
                    AboutWindowController.shared.show()
                }
            }
        }
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

enum AppFonts {
    static let helveticaNeueRegular = "Helvetica Neue"
    static let helveticaNeueLTStdBold = "HelveticaNeueLTStd-Bd"

    static func registerAll() {
        registerFont(named: "Helvetica Neue LT Std 75 Bold", extension: "otf")
    }

    private static func registerFont(named name: String, extension fileExtension: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            return
        }

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
