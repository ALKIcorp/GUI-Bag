import AppKit
import SwiftUI

private enum LaunchWindowMetrics {
    static let splashSize = NSSize(width: 784, height: 504)
    static let mainSize = NSSize(width: 1100, height: 760)
}

struct LaunchRootView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .background(
            LaunchWindowConfigurator(mode: isShowingSplash ? .splash : .main)
        )
        .task {
            guard isShowingSplash else { return }
            try? await Task.sleep(for: .milliseconds(1800))

            if Task.isCancelled {
                return
            }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    isShowingSplash = false
                }
            }
        }
    }
}

private struct SplashScreenView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("GUIBagSplashIcon")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 15)

            Image("GUIBagTextLogo")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 520)

            (
                Text("by ")
                    .font(.custom(AppFonts.helveticaNeueRegular, size: 23))
                +
                Text("Alki Corp.")
                    .font(.custom(AppFonts.helveticaNeueLTStdBold, size: 23))
            )
            .foregroundStyle(.white.opacity(0.9))

            Text("All Rights Reserved.")
                .font(.custom(AppFonts.helveticaNeueLTStdBold, size: 17))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 10)
        }
        .padding(.horizontal, 54)
        .padding(.vertical, 36)
        .frame(width: LaunchWindowMetrics.splashSize.width, height: LaunchWindowMetrics.splashSize.height)
        .background(Color.clear)
    }
}

private struct LaunchWindowConfigurator: NSViewRepresentable {
    enum Mode {
        case splash
        case main
    }

    let mode: Mode

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            configureWindow(for: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configureWindow(for: nsView)
        }
    }

    private func configureWindow(for view: NSView) {
        guard let window = view.window else { return }

        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.toolbar = nil
        window.isMovableByWindowBackground = true
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

        switch mode {
        case .splash:
            window.hasShadow = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            center(window: window, contentSize: LaunchWindowMetrics.splashSize)
            window.minSize = LaunchWindowMetrics.splashSize
        case .main:
            window.hasShadow = true
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false
            center(window: window, contentSize: LaunchWindowMetrics.mainSize)
            window.minSize = LaunchWindowMetrics.mainSize
        }
    }

    private func center(window: NSWindow, contentSize: NSSize) {
        let frameSize = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
        let visibleFrame = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? NSRect(origin: .zero, size: frameSize)
        let origin = NSPoint(
            x: visibleFrame.midX - (frameSize.width / 2),
            y: visibleFrame.midY - (frameSize.height / 2)
        )

        window.setFrame(NSRect(origin: origin, size: frameSize), display: true)
    }
}
