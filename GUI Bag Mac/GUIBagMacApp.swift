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
