import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var pendingNewItemName = ""
    @State private var isShowingAddModal = false
    @AppStorage("selectedThemeName") private var selectedThemeName = ConsoleThemePreset.presets.first?.name ?? "Crimson Glass"

    var body: some View {
        let theme = ConsoleThemePreset.named(selectedThemeName)

        GeometryReader { proxy in
            ZStack {
                WindowBackgroundGlass(theme: theme)
                    .ignoresSafeArea()

                Color.black.opacity(0.06)
                    .ignoresSafeArea()

                ConsoleWindow(
                    model: model,
                    theme: theme,
                    onThemeSelected: { selectedThemeName = $0.name },
                    onAdd: {
                        pendingNewItemName = model.nextDefaultName()
                        isShowingAddModal = true
                    }
                )
                .frame(
                    width: min(max(proxy.size.width - 48, 960), 1380),
                    height: min(max(proxy.size.height - 48, 700), 920)
                )

                if isShowingAddModal {
                    AddItemOverlay(
                        theme: theme,
                        itemName: $pendingNewItemName,
                        onClose: {
                            isShowingAddModal = false
                            pendingNewItemName = ""
                        },
                        onConfirm: {
                            model.addItem(named: pendingNewItemName)
                            isShowingAddModal = false
                            pendingNewItemName = ""
                        }
                    )
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .frame(minWidth: 1100, minHeight: 760)
        .background(WindowTransparencyConfigurator())
        .animation(.easeInOut(duration: 0.18), value: isShowingAddModal)
    }
}

private struct ConsoleThemePreset: Identifiable, Equatable {
    let name: String
    let appBg: Color
    let panel: Color
    let panel2: Color
    let accent: Color
    let accent2: Color
    let text: Color
    let mutedText: Color
    let stroke: Color
    let editorBg: Color
    let previewBg: Color
    let success: Color
    let danger: Color

    var id: String { name }

    var shell: Color { editorBg }
    var topRed: Color { panel2 }
    var bottomRed: Color { panel }
    var panelDeep: Color { editorBg }
    var selectedLight: Color { accent }
    var selectedText: Color { panel }
    var textPrimary: Color { text }
    var textSecondary: Color { mutedText }
    var textMuted: Color { mutedText }
    var accentPink: Color { accent2 }
    var blue: Color { accent2 }

    static func named(_ name: String) -> ConsoleThemePreset {
        presets.first(where: { $0.name == name }) ?? presets[0]
    }

    static let presets: [ConsoleThemePreset] = [
        .init(name: "Crimson Glass", appBg: .hex("0A0A0D"), panel: .hex("9E1633"), panel2: .hex("7C1028"), accent: .hex("F4F4F2"), accent2: .hex("FF7A9E"), text: .hex("FFF7FA"), mutedText: .hex("D7B8C2"), stroke: .hex("2A0F17"), editorBg: .hex("050507"), previewBg: .hex("F3F3F1"), success: .hex("4DD08A"), danger: .hex("FF4D6D")),
        .init(name: "Obsidian Ice", appBg: .hex("05070A"), panel: .hex("111827"), panel2: .hex("1C2533"), accent: .hex("DDF4FF"), accent2: .hex("6FD3FF"), text: .hex("F5FBFF"), mutedText: .hex("9FB2C4"), stroke: .hex("243041"), editorBg: .hex("030508"), previewBg: .hex("EAF6FF"), success: .hex("52D9A6"), danger: .hex("FF6B7A")),
        .init(name: "Royal Plum", appBg: .hex("0D0812"), panel: .hex("4B1E5A"), panel2: .hex("341240"), accent: .hex("F5D8FF"), accent2: .hex("C77DFF"), text: .hex("FFF6FF"), mutedText: .hex("C9A8D5"), stroke: .hex("221028"), editorBg: .hex("07040A"), previewBg: .hex("F8F2FF"), success: .hex("49D18A"), danger: .hex("FF5D87")),
        .init(name: "Emerald Noir", appBg: .hex("06100D"), panel: .hex("0F5C4A"), panel2: .hex("0B4336"), accent: .hex("D9FFF3"), accent2: .hex("55E6B5"), text: .hex("F3FFF9"), mutedText: .hex("A6D3C5"), stroke: .hex("103028"), editorBg: .hex("040806"), previewBg: .hex("ECFFF8"), success: .hex("6EF0A6"), danger: .hex("FF6A6A")),
        .init(name: "Bronze Luxe", appBg: .hex("110C08"), panel: .hex("7A4A2C"), panel2: .hex("5B351E"), accent: .hex("F8E7D8"), accent2: .hex("D9A066"), text: .hex("FFF8F1"), mutedText: .hex("D0B49C"), stroke: .hex("2B1A10"), editorBg: .hex("080503"), previewBg: .hex("FFF5EC"), success: .hex("63D79B"), danger: .hex("FF6E5B")),
        .init(name: "Arctic Mint", appBg: .hex("081012"), panel: .hex("A7F0E9"), panel2: .hex("74D9D0"), accent: .hex("0E2A2C"), accent2: .hex("E8FFFD"), text: .hex("F8FFFF"), mutedText: .hex("A7C7C8"), stroke: .hex("204245"), editorBg: .hex("0A1415"), previewBg: .hex("F2FFFE"), success: .hex("42D392"), danger: .hex("FF647C")),
        .init(name: "Graphite Orange", appBg: .hex("0B0B0C"), panel: .hex("1A1A1E"), panel2: .hex("24242A"), accent: .hex("FF9F43"), accent2: .hex("FFD7A8"), text: .hex("FFF8F0"), mutedText: .hex("B7ADA2"), stroke: .hex("35353D"), editorBg: .hex("050506"), previewBg: .hex("FFF4E8"), success: .hex("59D68D"), danger: .hex("FF5A5F")),
        .init(name: "Soft Sand", appBg: .hex("15120E"), panel: .hex("D7C2A4"), panel2: .hex("B89E7B"), accent: .hex("5B4330"), accent2: .hex("FFF4E6"), text: .hex("FFFDF8"), mutedText: .hex("C7BAAA"), stroke: .hex("6E5B46"), editorBg: .hex("0E0A07"), previewBg: .hex("FFF9F0"), success: .hex("6BCB95"), danger: .hex("E96A5F")),
        .init(name: "Candy Core", appBg: .hex("120914"), panel: .hex("FF4FA3"), panel2: .hex("D92C82"), accent: .hex("FFF0F7"), accent2: .hex("7DF9FF"), text: .hex("FFF8FC"), mutedText: .hex("E3B6CB"), stroke: .hex("4A1830"), editorBg: .hex("09040A"), previewBg: .hex("FFF5FA"), success: .hex("54E29B"), danger: .hex("FF5C8A")),
        .init(name: "Ocean Terminal", appBg: .hex("06131A"), panel: .hex("0E7490"), panel2: .hex("125D73"), accent: .hex("D6F6FF"), accent2: .hex("7CE2FF"), text: .hex("F3FCFF"), mutedText: .hex("A7C9D1"), stroke: .hex("123543"), editorBg: .hex("040A0D"), previewBg: .hex("EEFBFF"), success: .hex("51D9A4"), danger: .hex("FF6B6B")),
        .init(name: "Acid Lime", appBg: .hex("0A0D05"), panel: .hex("7FBF00"), panel2: .hex("5F9300"), accent: .hex("F6FFE0"), accent2: .hex("D7FF70"), text: .hex("FAFFF0"), mutedText: .hex("C4D49B"), stroke: .hex("28330E"), editorBg: .hex("060803"), previewBg: .hex("F9FFF0"), success: .hex("64E08C"), danger: .hex("FF5D5D")),
        .init(name: "Midnight Rose", appBg: .hex("09080C"), panel: .hex("6B1F3A"), panel2: .hex("4C1628"), accent: .hex("FFDCE8"), accent2: .hex("FF8FB1"), text: .hex("FFF7FA"), mutedText: .hex("D2ACB8"), stroke: .hex("241119"), editorBg: .hex("050407"), previewBg: .hex("FFF2F7"), success: .hex("57D58F"), danger: .hex("FF5878")),
        .init(name: "Steel Blue Pro", appBg: .hex("0A0E14"), panel: .hex("2B4257"), panel2: .hex("1E3142"), accent: .hex("E4F1FF"), accent2: .hex("8DBDFF"), text: .hex("F7FAFF"), mutedText: .hex("AAB7C6"), stroke: .hex("24313F"), editorBg: .hex("06090D"), previewBg: .hex("F0F7FF"), success: .hex("5ED39A"), danger: .hex("FF6D6D")),
        .init(name: "Ivory Cherry", appBg: .hex("1A1516"), panel: .hex("F6F1EC"), panel2: .hex("E6D8D1"), accent: .hex("9F1D35"), accent2: .hex("FFB3C1"), text: .hex("1C1718"), mutedText: .hex("7B6D6F"), stroke: .hex("C9B4B0"), editorBg: .hex("0F0B0C"), previewBg: .hex("FFFDFC"), success: .hex("2FAF73"), danger: .hex("D6455D")),
        .init(name: "Neon Grape", appBg: .hex("08050D"), panel: .hex("2C114A"), panel2: .hex("1D0B33"), accent: .hex("B517FF"), accent2: .hex("6EF3FF"), text: .hex("FAF4FF"), mutedText: .hex("BBA9CB"), stroke: .hex("2F1E42"), editorBg: .hex("040208"), previewBg: .hex("F8F1FF"), success: .hex("4DDB94"), danger: .hex("FF5A7A"))
    ]
}

private extension Color {
    static func hex(_ value: String) -> Color {
        let hex = value.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        return Color(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }

    var cssHex: String {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? .white
        let red = Int(round(nsColor.redComponent * 255))
        let green = Int(round(nsColor.greenComponent * 255))
        let blue = Int(round(nsColor.blueComponent * 255))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

private struct WindowBackgroundGlass: NSViewRepresentable {
    let theme: ConsoleThemePreset

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.material = .underWindowBackground
        view.state = .active
        view.isEmphasized = false
        view.alphaValue = 0.24
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = .underWindowBackground
        nsView.state = .active
        nsView.alphaValue = 0.24
        nsView.wantsLayer = true
        nsView.layer?.backgroundColor = NSColor(theme.appBg).withAlphaComponent(0.18).cgColor
    }
}

private struct WindowTransparencyConfigurator: NSViewRepresentable {
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
        window.hasShadow = true
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    }
}

private struct ConsoleWindow: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    let onThemeSelected: (ConsoleThemePreset) -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CanvasSection(model: model, theme: theme, onAdd: onAdd)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)

            HandleDivider(theme: theme)

            BottomSection(model: model, theme: theme, onThemeSelected: onThemeSelected, onAdd: onAdd)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
        }
        .padding(8)
        .background(theme.shell)
        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(theme.text.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.85), radius: 60, x: 0, y: 30)
    }
}

private struct CanvasSection: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    let onAdd: () -> Void
    @State private var isShowingExpandedCanvas = false

    var body: some View {
        ZStack {
            theme.topRed

            DotPatternOverlay()
                .opacity(0.10)

            CanvasWorkspace(
                model: model,
                theme: theme,
                showsExpandControl: true,
                onExpand: { isShowingExpandedCanvas = true }
            )
                .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(theme.stroke.opacity(0.85), lineWidth: 8)
        )
        .sheet(isPresented: $isShowingExpandedCanvas) {
            ExpandedCanvasSheet(model: model, theme: theme)
        }
    }
}

private struct DotPatternOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let step: CGFloat = 8
                let dotSize: CGFloat = 2

                for x in stride(from: 0, through: size.width, by: step) {
                    for y in stride(from: 0, through: size.height, by: step) {
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                        context.fill(Path(ellipseIn: rect), with: .color(.black))
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
    }
}

private struct CanvasWorkspace: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    let showsExpandControl: Bool
    let onExpand: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            CanvasToolbar(
                model: model,
                theme: theme,
                showsExpandControl: showsExpandControl,
                onExpand: onExpand
            )

            if model.items.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(theme.previewBg)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.stroke, lineWidth: 4)

                    ConsoleEmptyState(
                        theme: theme,
                        title: "NO CANVAS",
                        message: "Add a tab to open a design canvas."
                    )
                }
            } else {
                CanvasCard(
                    item: model.currentItem ?? model.items[0],
                    theme: theme,
                    zoomScale: model.canvasZoom,
                    isActive: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 14)
    }
}

private func makeCanvasHTML(for item: StoredItem, theme: ConsoleThemePreset) -> String {
    return """
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
          html, body {
            margin: 0;
            min-height: 100%;
            background: \(theme.previewBg.cssHex);
            color: \(theme.text.cssHex);
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
          }
          body {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            box-sizing: border-box;
          }
          \(item.css)
        </style>
      </head>
      <body>
        \(item.html)
        <script>\(item.js)</script>
      </body>
    </html>
    """
}

private struct CanvasToolbar: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    let showsExpandControl: Bool
    let onExpand: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(spacing: 10) {
                GlassTabRail(theme: theme) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(model.openTabs) { item in
                                CanvasTabButton(
                                    item: item,
                                    theme: theme,
                                    isSelected: model.selectedID == item.id
                                ) {
                                    model.selectTab(id: item.id)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                .layoutPriority(1)

                CanvasAddTabButton(theme: theme) {
                    model.addItem()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(theme.text.opacity(0.08))
                .frame(width: 1, height: 30)

            CanvasControlCluster(theme: theme, model: model, showsExpandControl: showsExpandControl, onExpand: onExpand)
                .fixedSize()
                .layoutPriority(1)
        }
    }
}

private struct CanvasCard: View {
    let item: StoredItem
    let theme: ConsoleThemePreset
    let zoomScale: CGFloat
    let isActive: Bool

    var body: some View {
        VStack(spacing: 0) {
            CanvasHeader(theme: theme, item: item, isActive: isActive, zoomScale: zoomScale)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(theme.previewBg)

                CanvasRendererView(html: makeCanvasHTML(for: item, theme: theme), zoomScale: zoomScale)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(8)
            }
            .padding(10)
        }
        .background(theme.editorBg.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isActive ? theme.accent2.opacity(0.75) : theme.stroke, lineWidth: isActive ? 3 : 2)
        )
        .shadow(color: .black.opacity(isActive ? 0.24 : 0.16), radius: isActive ? 18 : 10, x: 0, y: 12)
    }
}

private struct CanvasHeader: View {
    let theme: ConsoleThemePreset
    let item: StoredItem
    let isActive: Bool
    let zoomScale: CGFloat

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme.accent2)
                .frame(width: 24, height: 24)
                .background(theme.accent2.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)

                Text("Canvas • \(Int(zoomScale * 100))%")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if isActive {
                Image(systemName: "sparkles.tv")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.accent2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(theme.panel2.opacity(0.96))
    }
}

private struct CanvasControlCluster: View {
    let theme: ConsoleThemePreset
    @ObservedObject var model: AppModel
    let showsExpandControl: Bool
    let onExpand: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            GlassTabAccessory(theme: theme) {
                HStack(spacing: 8) {
                    Button(action: model.zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    .buttonStyle(.plain)

                    Menu {
                        ForEach(CanvasZoomPreset.allCases) { preset in
                            Button(preset.title) {
                                model.canvasZoom = preset.scale
                            }
                        }
                    } label: {
                        Text("\(Int(model.canvasZoom * 100))%")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .frame(minWidth: 42)
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()

                    Button(action: model.zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .buttonStyle(.plain)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            }

            if showsExpandControl {
                GlassTabAccessory(theme: theme) {
                    Button(action: onExpand) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(theme.textPrimary)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CanvasAddTabButton: View {
    let theme: ConsoleThemePreset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassTabAccessory(theme: theme, prominence: 0.14) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(theme.textSecondary)
                    .frame(width: 30, height: 30)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct GlassTabRail<Content: View>: View {
    let theme: ConsoleThemePreset
    let content: Content

    init(theme: ConsoleThemePreset, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(
                    .regular
                        .tint(theme.accent.opacity(0.10)),
                    in: .rect(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.text.opacity(0.08), lineWidth: 1)
                )
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(theme.text.opacity(0.08), lineWidth: 1)
                )
        }
    }
}

private struct CanvasTabButton: View {
    let item: StoredItem
    let theme: ConsoleThemePreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? theme.accent2 : theme.textSecondary.opacity(0.35))
                    .frame(width: 6, height: 6)

                Text(item.name)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .truncationMode(.tail)
                    .lineLimit(1)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .black))
                }
            }
            .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary.opacity(0.82))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundShape)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 220)
        .zIndex(isSelected ? 1 : 0)
    }

    @ViewBuilder
    private var backgroundShape: some View {
        if isSelected {
            GlassTabAccessory(theme: theme, prominence: 0.30) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(theme.text.opacity(0.05), lineWidth: 1)
                )
        }
    }
}

private struct GlassTabAccessory<Content: View>: View {
    let theme: ConsoleThemePreset
    var prominence: Double = 0.18
    let content: Content

    init(theme: ConsoleThemePreset, prominence: Double = 0.18, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.prominence = prominence
        self.content = content()
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            content
                .padding(.horizontal, 2)
                .glassEffect(
                    .regular
                        .tint(theme.accent.opacity(prominence))
                        .interactive(),
                    in: .capsule
                )
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(theme.text.opacity(0.10), lineWidth: 1)
                )
        }
    }
}

private struct ExpandedCanvasSheet: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            WindowBackgroundGlass(theme: theme)
                .ignoresSafeArea()

            LinearGradient(
                colors: [theme.appBg.opacity(0.96), theme.panel2.opacity(0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Text("EXPANDED CANVAS")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }

                CanvasWorkspace(model: model, theme: theme, showsExpandControl: false, onExpand: {})
            }
            .padding(24)
        }
        .frame(minWidth: 1200, minHeight: 760)
    }
}

private struct HandleDivider: View {
    let theme: ConsoleThemePreset

    var body: some View {
        HStack {
            Capsule()
                .fill(theme.panelDeep.opacity(0.9))
                .frame(width: 56, height: 6)

            Spacer()

            Capsule()
                .fill(theme.panelDeep.opacity(0.9))
                .frame(width: 56, height: 6)
        }
        .padding(.horizontal, 64)
        .frame(height: 24)
        .background(theme.shell)
    }
}

private struct BottomSection: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    let onThemeSelected: (ConsoleThemePreset) -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                EditorPanel(
                    theme: theme,
                    currentItem: model.currentItem,
                    activeTab: $model.activeTab,
                    code: model.codeBinding,
                    statusText: model.statusText
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ItemListPanel(
                    theme: theme,
                    items: model.items,
                    selectedID: $model.selectedID,
                    rename: model.renameItem,
                    currentItem: model.currentItem
                )
                .frame(width: 320)
            }

            FooterBar(
                theme: theme,
                onThemeSelected: onThemeSelected,
                canRemove: model.items.count > 1 && model.currentItem != nil,
                onAdd: onAdd,
                onRemove: model.deleteSelectedItem,
                onExportBackup: model.exportBackup,
                onImportBackup: model.importBackup
            )
        }
        .background(theme.bottomRed)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(theme.stroke.opacity(0.85), lineWidth: 8)
        )
    }
}

private struct EditorPanel: View {
    let theme: ConsoleThemePreset
    let currentItem: StoredItem?
    @Binding var activeTab: EditorTab
    let code: (EditorTab) -> Binding<String>
    let statusText: String
    @State private var collapsedSections: Set<EditorTab> = []

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text((currentItem?.name ?? "NO_ITEM").uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .italic()
                        .tracking(1.2)
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)

                    Text((currentItem?.type ?? "UNASSIGNED").uppercased())
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(1)
                }
                .frame(width: 118, alignment: .leading)

                HStack(spacing: 8) {
                    ForEach(EditorTab.allCases) { tab in
                        TabButton(theme: theme, tab: tab, isSelected: activeTab == tab) {
                            activeTab = tab
                        }
                    }
                }
                .padding(.top, 1)

                Spacer(minLength: 0)

                Text(statusText.uppercased())
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .tracking(1.8)
                    .foregroundStyle(theme.accentPink.opacity(0.8))
                    .padding(.top, 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
            .padding(.trailing, 14)
            .padding(.top, 4)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.panelDeep.opacity(0.98))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(theme.stroke, lineWidth: 4)

                VStack(spacing: 0) {
                    HStack {
                        Text("\(activeTab.rawValue).alki")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .italic()
                            .tracking(1.6)
                            .foregroundStyle(theme.accentPink.opacity(0.9))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(theme.panel2)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                            .frame(height: 2)
                    }

                    if currentItem == nil {
                        ConsoleEmptyState(
                            theme: theme,
                            title: "NO CONTENT",
                            message: "Select an item to edit HTML, CSS, JS, or ALL."
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if activeTab == .all {
                        AllTabEditor(theme: theme, code: code, collapsedSections: $collapsedSections)
                    } else {
                        TextEditor(text: code(activeTab))
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundStyle(theme.accentPink)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(theme.panelDeep.opacity(0.001))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 2)
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

private struct AllTabEditor: View {
    let theme: ConsoleThemePreset
    let code: (EditorTab) -> Binding<String>
    @Binding var collapsedSections: Set<EditorTab>

    private let tabs: [EditorTab] = [.html, .css, .js]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(tabs) { tab in
                    EditorSectionCard(
                        theme: theme,
                        tab: tab,
                        text: code(tab),
                        isCollapsed: collapsedSections.contains(tab),
                        toggle: { toggle(tab) }
                    )
                }
            }
            .padding(12)
        }
        .background(theme.panelDeep.opacity(0.001))
    }

    private func toggle(_ tab: EditorTab) {
        if collapsedSections.contains(tab) {
            collapsedSections.remove(tab)
        } else {
            collapsedSections.insert(tab)
        }
    }
}

private struct EditorSectionCard: View {
    let theme: ConsoleThemePreset
    let tab: EditorTab
    @Binding var text: String
    let isCollapsed: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: toggle) {
                HStack(spacing: 8) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(theme.textSecondary)

                    Text(sectionTitle)
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .tracking(1.8)
                        .foregroundStyle(sectionColor)

                    Spacer()

                    Text(isCollapsed ? "EXPAND" : "MINIMIZE")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .tracking(1.4)
                        .foregroundStyle(theme.textSecondary.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(theme.panel2)
            }
            .buttonStyle(.plain)

            if !isCollapsed {
                TextEditor(text: $text)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(sectionColor)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(theme.panelDeep.opacity(0.001))
            }
        }
        .background(theme.panel2.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(theme.text.opacity(0.08), lineWidth: 1)
        )
    }

    private var sectionTitle: String {
        switch tab {
        case .html:
            return "HTML"
        case .css:
            return "CSS"
        case .js:
            return "JAVASCRIPT"
        case .all:
            return "ALL"
        }
    }

    private var sectionColor: Color {
        switch tab {
        case .html:
            return theme.accentPink
        case .css:
            return theme.accent
        case .js:
            return theme.text
        case .all:
            return theme.textPrimary
        }
    }
}

private struct TabButton: View {
    let theme: ConsoleThemePreset
    let tab: EditorTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 14, weight: .black))
                Text(tab.title)
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .tracking(0.8)
            }
            .frame(width: 40, height: 40)
            .foregroundStyle(isSelected ? theme.bottomRed : theme.textPrimary)
            .background(isSelected ? theme.selectedLight : theme.topRed.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? theme.accent : theme.text.opacity(0.10), lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.35 : 0), radius: 12, x: 0, y: 6)
            .scaleEffect(isSelected ? 1.04 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct ItemListPanel: View {
    let theme: ConsoleThemePreset
    let items: [StoredItem]
    @Binding var selectedID: String?
    let rename: (String, String) -> Void
    let currentItem: StoredItem?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        ItemRow(
                            theme: theme,
                            item: item,
                            isSelected: item.id == selectedID,
                            onSelect: { selectedID = item.id },
                            onRename: { rename(item.id, $0) }
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 18)
            .padding(.bottom, 16)

            if let currentItem {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE PROFILE")
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(theme.textMuted)
                    Text(currentItem.name.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    Text(currentItem.type.uppercased())
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(theme.panelDeep.opacity(0.45))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(theme.stroke)
                        .frame(height: 2)
                }
            }
        }
        .background(theme.panel2)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.stroke)
                .frame(width: 4)
        }
    }
}

private struct ItemRow: View {
    let theme: ConsoleThemePreset
    let item: StoredItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onRename: (String) -> Void

    @State private var isEditing = false
    @State private var draftName = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            PolygonRowShape()
                .fill(isSelected ? theme.selectedLight : theme.panelDeep.opacity(0.82))

            Group {
                if isEditing {
                    TextField("", text: $draftName)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .italic()
                        .textCase(.uppercase)
                        .foregroundStyle(isSelected ? theme.selectedText : theme.textPrimary)
                        .focused($isFocused)
                        .onSubmit(commitRename)
                        .onExitCommand(perform: cancelRename)
                        .onChange(of: isFocused) { focused in
                            if !focused && isEditing {
                                commitRename()
                            }
                        }
                } else {
                    Text(item.name.uppercased())
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .italic()
                        .tracking(-0.2)
                        .foregroundStyle(isSelected ? theme.selectedText : theme.textMuted)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 36)
        .contentShape(PolygonRowShape())
        .shadow(color: isSelected ? .black.opacity(0.18) : .clear, radius: 6, x: 0, y: 4)
        .offset(x: isSelected ? 4 : 0)
        .onTapGesture(perform: onSelect)
        .onTapGesture(count: 2, perform: beginEditing)
    }

    private func beginEditing() {
        onSelect()
        draftName = item.name
        isEditing = true
        DispatchQueue.main.async {
            isFocused = true
        }
    }

    private func commitRename() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != item.name {
            onRename(trimmed)
        }
        isEditing = false
        draftName = ""
    }

    private func cancelRename() {
        isEditing = false
        draftName = ""
    }
}

private struct PolygonRowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = rect.width * 0.05
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width - inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width - inset, y: rect.height))
        path.addLine(to: CGPoint(x: inset, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct FooterBar: View {
    let theme: ConsoleThemePreset
    let onThemeSelected: (ConsoleThemePreset) -> Void
    let canRemove: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onExportBackup: () -> Void
    let onImportBackup: () -> Void
    @State private var isShowingSettings = false

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(theme.mutedText.opacity(0.7))

                Text("ALKI_SYS")
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .italic()
                    .tracking(1.6)
                    .foregroundStyle(theme.mutedText.opacity(0.88))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(theme.panel2.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(theme.text.opacity(0.05), lineWidth: 1)
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(theme.mutedText.opacity(0.7))
            }

            Spacer()

            HStack(spacing: 10) {
                FooterActionButton(
                    color: theme.success,
                    shadow: theme.appBg.opacity(0.9),
                    systemImage: "plus"
                ) {
                    onAdd()
                }

                FooterActionButton(
                    color: theme.danger,
                    shadow: theme.appBg.opacity(0.9),
                    systemImage: "trash"
                ) {
                    onRemove()
                }
                .disabled(!canRemove)

                Button(action: { isShowingSettings.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 11, weight: .black))
                        Text("SETTINGS")
                            .font(.system(size: 8, weight: .black, design: .rounded))
                            .tracking(1.1)
                    }
                    .foregroundStyle(theme.previewBg)
                    .padding(.horizontal, 12)
                    .frame(height: 28)
                    .background(theme.blue)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(theme.accent, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                .popover(isPresented: $isShowingSettings, arrowEdge: .bottom) {
                    ThemeSettingsPopover(
                        theme: theme,
                        onThemeSelected: onThemeSelected,
                        onExportBackup: {
                            isShowingSettings = false
                            onExportBackup()
                        },
                        onImportBackup: {
                            isShowingSettings = false
                            onImportBackup()
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(theme.appBg.opacity(0.72))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.stroke)
                .frame(height: 2)
        }
    }
}

private struct ThemeSettingsPopover: View {
    let theme: ConsoleThemePreset
    let onThemeSelected: (ConsoleThemePreset) -> Void
    let onExportBackup: () -> Void
    let onImportBackup: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THEME PRESETS")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(theme.accentPink)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(ConsoleThemePreset.presets) { preset in
                        Button {
                            onThemeSelected(preset)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(preset.name.uppercased())
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundStyle(preset.text)

                                    Spacer()

                                    if preset == theme {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(preset.accent)
                                    }
                                }

                                HStack(spacing: 6) {
                                    ThemeSwatch(color: preset.appBg)
                                    ThemeSwatch(color: preset.panel)
                                    ThemeSwatch(color: preset.panel2)
                                    ThemeSwatch(color: preset.accent)
                                    ThemeSwatch(color: preset.accent2)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(preset.panel)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(preset == theme ? preset.accent2 : preset.stroke, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(width: 320, height: 360)

            VStack(alignment: .leading, spacing: 8) {
                Text("BACKUPS")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(theme.textPrimary)

                HStack(spacing: 8) {
                    BackupActionButton(
                        title: "SAVE BACKUP",
                        systemImage: "square.and.arrow.down",
                        color: theme.success,
                        textColor: theme.editorBg,
                        action: onExportBackup
                    )

                    BackupActionButton(
                        title: "LOAD BACKUP",
                        systemImage: "square.and.arrow.up",
                        color: theme.accent2,
                        textColor: theme.previewBg,
                        action: onImportBackup
                    )
                }
            }
        }
        .padding(14)
        .background(theme.editorBg)
    }
}

private struct ThemeSwatch: View {
    let color: Color

    var body: some View {
        Capsule()
            .fill(color)
            .frame(height: 10)
    }
}

private struct FooterActionButton: View {
    let color: Color
    let shadow: Color
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(color)
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(.white)
            }
            .frame(width: 28, height: 28)
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(shadow)
                    .frame(height: 3)
                    .offset(y: 2)
            }
        }
        .buttonStyle(.plain)
        .opacity(1)
    }
}

private struct BackupActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let textColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .black))

                Text(title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.1)
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct AddItemOverlay: View {
    let theme: ConsoleThemePreset
    @Binding var itemName: String
    let onClose: () -> Void
    let onConfirm: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.82)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(theme.topRed.opacity(0.22))
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(theme.topRed.opacity(0.35), lineWidth: 1)
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(theme.topRed)
                            }
                            .frame(width: 40, height: 40)

                            Text("ADD NEW ITEM")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .italic()
                                .foregroundStyle(theme.textPrimary)
                        }

                        Spacer()

                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(theme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ITEM DESIGNATION")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(1.8)
                            .foregroundStyle(theme.topRed)

                        TextField("ENTER NAME...", text: $itemName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(theme.textPrimary)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(theme.panelDeep.opacity(0.96))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color(red: 0.12, green: 0.12, blue: 0.12), lineWidth: 2)
                            )
                            .focused($isFocused)
                            .onSubmit(confirm)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    VStack(spacing: 12) {
                        AngledModalButton(title: "CONFIRM ADDITION", foreground: .black, background: .white, action: confirm)
                        AngledModalButton(title: "CANCEL", foreground: theme.textMuted, background: theme.panel2, action: onClose)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    Rectangle()
                        .fill(theme.topRed.opacity(0.5))
                        .frame(height: 8)
                }
                .background(theme.panel2)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            }
            .padding(24)
            .frame(width: 460)
            .background(theme.bottomRed)
            .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.55), radius: 40, x: 0, y: 20)
        }
        .onAppear {
            DispatchQueue.main.async {
                isFocused = true
            }
        }
    }

    private func confirm() {
        let trimmed = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        itemName = trimmed
        onConfirm()
    }
}

private struct AngledModalButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .italic()
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(background)
                .clipShape(AngledButtonShape())
        }
        .buttonStyle(.plain)
    }
}

private struct AngledButtonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = rect.width * 0.05
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width - inset, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct ConsoleEmptyState: View {
    let theme: ConsoleThemePreset
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .italic()
                .tracking(1.1)
                .foregroundStyle(theme.textPrimary)
            Text(message.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1.1)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

enum EditorTab: String, CaseIterable, Identifiable {
    case html
    case css
    case js
    case all

    var id: String { rawValue }

    var title: String {
        rawValue.uppercased()
    }

    var iconName: String {
        switch self {
        case .html:
            return "chevron.left.forwardslash.chevron.right"
        case .css:
            return "curlybraces"
        case .js:
            return "terminal"
        case .all:
            return "doc.text"
        }
    }
}

enum CanvasZoomPreset: CGFloat, CaseIterable, Identifiable {
    case fifty = 0.5
    case seventyFive = 0.75
    case oneHundred = 1.0
    case oneTwentyFive = 1.25
    case oneFifty = 1.5
    case twoHundred = 2.0

    var id: CGFloat { rawValue }

    var scale: CGFloat { rawValue }

    var title: String {
        "\(Int(rawValue * 100))%"
    }
}

final class AppModel: ObservableObject {
    @Published var items: [StoredItem] = []
    @Published var selectedID: String? {
        didSet {
            guard selectedID != oldValue else { return }
            syncOpenTabs(previousSelectedID: oldValue, newSelectedID: selectedID)
        }
    }
    @Published private(set) var openTabIDs: [String] = []
    @Published var activeTab: EditorTab = .html
    @Published var canvasZoom: CGFloat = CanvasZoomPreset.oneHundred.scale
    @Published var statusText = "Ready"

    private let store: ItemStore
    private var pendingSave: PendingSave?

    private struct PendingSave {
        let id: String
        let patch: [String: String]
        let workItem: DispatchWorkItem
    }

    var currentItem: StoredItem? {
        items.first(where: { $0.id == selectedID }) ?? items.first
    }

    var openTabs: [StoredItem] {
        openTabIDs.compactMap { id in
            items.first(where: { $0.id == id })
        }
    }

    init() {
        do {
            self.store = try ItemStore()
            reload()
        } catch {
            fatalError("Failed to initialize item store: \(error.localizedDescription)")
        }
    }

    func codeBinding(for tab: EditorTab) -> Binding<String> {
        Binding(
            get: { [self] in
                guard let item = currentItem else { return "" }
                switch tab {
                case .html:
                    return item.html
                case .css:
                    return item.css
                case .js:
                    return item.js
                case .all:
                    return ""
                }
            },
            set: { [self] in updateCurrentCode(tab: tab, value: $0) }
        )
    }

    func addItem(named name: String? = nil) {
        do {
            let item = try store.createStoredItem(
                payload: CreateItemPayload(
                    name: resolvedItemName(from: name),
                    type: "UI Component",
                    html: "",
                    css: "",
                    js: "",
                    all: nil
                )
            )
            items.append(item)
            openTabIDs.append(item.id)
            selectedID = item.id
            statusText = "Added \(item.name)"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func deleteSelectedItem() {
        guard let id = currentItem?.id else { return }

        do {
            try store.deleteStoredItem(id: id)
            items.removeAll { $0.id == id }
            openTabIDs.removeAll { $0 == id }
            if openTabIDs.isEmpty, let firstID = items.first?.id {
                openTabIDs = [firstID]
            }
            selectedID = openTabIDs.first ?? items.first?.id
            statusText = "Deleted item"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func renameSelectedItem(_ value: String) {
        updateSelectedField("name", value: value)
    }

    func renameItem(id: String, to value: String) {
        guard items.contains(where: { $0.id == id }) else { return }
        updateLocalItem(id: id, field: "name", value: value)
        scheduleSave(id: id, patch: ["name": value])
    }

    func updateSelectedType(_ value: String) {
        updateSelectedField("type", value: value)
    }

    func exportBackup() {
        flushPendingSave()

        let savePanel = NSSavePanel()
        savePanel.title = "Save GUI Bag Backup"
        savePanel.message = "Choose where to save a backup of your saved UI components."
        savePanel.nameFieldStringValue = backupFileName()
        savePanel.allowedContentTypes = [.json]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false

        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            return
        }

        do {
            try store.exportBackup(to: url)
            statusText = "Backup saved"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func importBackup() {
        flushPendingSave()

        let openPanel = NSOpenPanel()
        openPanel.title = "Load GUI Bag Backup"
        openPanel.message = "Choose a backup file to import saved UI components."
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            return
        }

        do {
            let importedItems = try store.importBackup(from: url)
            items = try store.loadItems()
            let initialID = importedItems.last?.id ?? items.first?.id
            openTabIDs = initialID.map { [$0] } ?? []
            selectedID = initialID
            statusText = importedItems.isEmpty ? "Backup loaded" : "Imported \(importedItems.count) items"
        } catch {
            statusText = error.localizedDescription
        }
    }

    private func updateCurrentCode(tab: EditorTab, value: String) {
        switch tab {
        case .html:
            updateSelectedField("html", value: value)
        case .css:
            updateSelectedField("css", value: value)
        case .js:
            updateSelectedField("js", value: value)
        case .all:
            break
        }
    }

    private func updateSelectedField(_ field: String, value: String) {
        guard let id = currentItem?.id else { return }
        updateLocalItem(id: id, field: field, value: value)
        scheduleSave(id: id, patch: [field: value])
    }

    private func updateLocalItem(id: String, field: String, value: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        switch field {
        case "name":
            items[index].name = value
        case "type":
            items[index].type = value
        case "html":
            items[index].html = value
        case "css":
            items[index].css = value
        case "js":
            items[index].js = value
        case "all":
            items[index].all = value
        default:
            break
        }
    }

    private func scheduleSave(id: String, patch: [String: String]) {
        pendingSave?.workItem.cancel()
        statusText = "Saving..."

        let workItem = DispatchWorkItem { [weak self] in
            self?.persistPendingSave(id: id, patch: patch)
        }

        pendingSave = PendingSave(id: id, patch: patch, workItem: workItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    private func persistPendingSave(id: String, patch: [String: String]) {
        if pendingSave?.id == id, pendingSave?.patch == patch {
            pendingSave = nil
        }

        do {
            let item = try store.updateStoredItem(id: id, patch: patch)
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = item
            }
            statusText = "Saved"
        } catch {
            statusText = error.localizedDescription
        }
    }

    private func flushPendingSave() {
        guard let pendingSave else { return }
        pendingSave.workItem.cancel()
        self.pendingSave = nil
        persistPendingSave(id: pendingSave.id, patch: pendingSave.patch)
    }

    private func reload() {
        do {
            items = try store.loadItems()
            let firstID = items.first?.id
            openTabIDs = firstID.map { [$0] } ?? []
            selectedID = firstID
        } catch {
            statusText = error.localizedDescription
        }
    }

    func selectTab(id: String) {
        guard openTabIDs.contains(id) else { return }
        selectedID = id
    }

    private func syncOpenTabs(previousSelectedID: String?, newSelectedID: String?) {
        guard let newSelectedID else { return }

        if openTabIDs.contains(newSelectedID) {
            return
        }

        if openTabIDs.isEmpty {
            openTabIDs = [newSelectedID]
            return
        }

        if let previousSelectedID, let index = openTabIDs.firstIndex(of: previousSelectedID) {
            openTabIDs[index] = newSelectedID
        } else {
            openTabIDs = [newSelectedID]
        }

        var seen = Set<String>()
        openTabIDs = openTabIDs.filter { seen.insert($0).inserted }
    }

    func zoomIn() {
        setZoom(nextZoom(increasing: true))
    }

    func zoomOut() {
        setZoom(nextZoom(increasing: false))
    }

    private func setZoom(_ scale: CGFloat) {
        canvasZoom = min(max(scale, CanvasZoomPreset.allCases.first?.scale ?? 0.5), CanvasZoomPreset.allCases.last?.scale ?? 2.0)
    }

    private func nextZoom(increasing: Bool) -> CGFloat {
        let presets = CanvasZoomPreset.allCases.map(\.scale)
        if increasing {
            return presets.first(where: { $0 > canvasZoom + 0.001 }) ?? canvasZoom
        }
        return presets.last(where: { $0 < canvasZoom - 0.001 }) ?? canvasZoom
    }

    func nextDefaultName() -> String {
        let prefix = "UI Asset "
        let usedNumbers = items.compactMap { item -> Int? in
            guard item.name.hasPrefix(prefix) else { return nil }
            return Int(item.name.dropFirst(prefix.count))
        }
        return "\(prefix)\((usedNumbers.max() ?? 0) + 1)"
    }

    private func resolvedItemName(from name: String?) -> String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nextDefaultName() : trimmed
    }

    private func backupFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return "GUI-Bag-Backup-\(formatter.string(from: Date())).json"
    }
}
