import AppKit
import SwiftUI

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
        VStack(spacing: 18) {
            Group {
                if let icon = BundledApplicationIcon.nsImage() {
                    Image(nsImage: icon)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                } else {
                    Image("GUIBagSplashIcon")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                }
            }
            .frame(width: 154, height: 154)
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 12)

            Image("GUIBagTextLogo")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 320)

            (
                Text("by ")
                    .font(.custom(AppFonts.helveticaNeueRegular, size: 14))
                +
                Text("Alki Corp.")
                    .font(.custom(AppFonts.helveticaNeueLTStdBold, size: 14))
            )
            .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 32)
        .frame(width: 560, height: 360)
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
            window.setContentSize(NSSize(width: 560, height: 360))
            window.minSize = NSSize(width: 560, height: 360)
            window.center()
        case .main:
            window.hasShadow = true
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false
            window.setContentSize(NSSize(width: 1100, height: 760))
            window.minSize = NSSize(width: 1100, height: 760)
            window.center()
        }
    }
}
