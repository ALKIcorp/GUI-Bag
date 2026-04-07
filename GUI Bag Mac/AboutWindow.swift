import AppKit
import SwiftUI

enum AppMetadata {
    static let categoryLabel = "Developer Tools."

    static var displayName: String {
        if let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !value.isEmpty {
            return value
        }

        if let value = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String,
           !value.isEmpty {
            return value
        }

        return ProcessInfo.processInfo.processName
    }

    static var buildVersionLine: String {
        let build = (Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !build.isEmpty else { return "Version" }
        return "Version (\(build))"
    }
}

@MainActor
final class AboutWindowController {
    static let shared = AboutWindowController()

    private var panel: NSPanel?

    func show() {
        let panel = panel ?? makePanel()
        self.panel = panel
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 330),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.contentView = NSHostingView(rootView: AboutPanelView())
        return panel
    }
}

private struct AboutPanelView: View {
    var body: some View {
        VStack(spacing: 18) {
            appIcon

            VStack(spacing: 8) {
                Text(AppMetadata.displayName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(AppMetadata.buildVersionLine)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                Text("Category: \(AppMetadata.categoryLabel)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .padding(.vertical, 36)
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    @ViewBuilder
    private var appIcon: some View {
        if let image = BundledApplicationIcon.nsImage() {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 84, height: 84)
        }
    }
}
