import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var pendingNewItemName = ""
    @State private var isShowingAddModal = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                WindowBackgroundGlass()
                    .ignoresSafeArea()

                Color.black.opacity(0.06)
                    .ignoresSafeArea()

                ConsoleWindow(
                    model: model,
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

private enum ConsoleTheme {
    static let shell = Color(red: 0.08, green: 0.08, blue: 0.08)
    static let topRed = Color(red: 0.49, green: 0.10, blue: 0.16)
    static let bottomRed = Color(red: 0.66, green: 0.11, blue: 0.23)
    static let panel = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let panelDeep = Color.black
    static let selectedLight = Color.white
    static let selectedText = Color.black
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.58)
    static let textMuted = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let accentPink = Color(red: 0.95, green: 0.35, blue: 0.56)
    static let success = Color(red: 0.15, green: 0.67, blue: 0.33)
    static let danger = Color(red: 0.86, green: 0.17, blue: 0.24)
    static let blue = Color(red: 0.16, green: 0.42, blue: 0.92)
}

private struct WindowBackgroundGlass: NSViewRepresentable {
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
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PreviewSection(item: model.currentItem)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)

            HandleDivider()

            BottomSection(model: model, onAdd: onAdd)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
        }
        .padding(8)
        .background(ConsoleTheme.shell)
        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.85), radius: 60, x: 0, y: 30)
    }
}

private struct PreviewSection: View {
    let item: StoredItem?

    var body: some View {
        ZStack {
            ConsoleTheme.topRed

            DotPatternOverlay()
                .opacity(0.10)

            PreviewFrame(item: item)
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.black.opacity(0.25), lineWidth: 8)
        )
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

private struct PreviewFrame: View {
    let item: StoredItem?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ConsoleTheme.selectedLight)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ConsoleTheme.shell, lineWidth: 4)

            if let item {
                PreviewWebView(html: makePreviewHTML(for: item))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                ConsoleEmptyState(
                    title: "LINK OFFLINE",
                    message: "Add an item to render the preview frame."
                )
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 14)
    }

}

private func makePreviewHTML(for item: StoredItem) -> String {
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
            background: #111111;
            color: white;
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

private struct HandleDivider: View {
    var body: some View {
        HStack {
            Capsule()
                .fill(ConsoleTheme.panelDeep.opacity(0.9))
                .frame(width: 56, height: 6)

            Spacer()

            Capsule()
                .fill(ConsoleTheme.panelDeep.opacity(0.9))
                .frame(width: 56, height: 6)
        }
        .padding(.horizontal, 64)
        .frame(height: 24)
        .background(ConsoleTheme.shell)
    }
}

private struct BottomSection: View {
    @ObservedObject var model: AppModel
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                EditorPanel(
                    currentItem: model.currentItem,
                    activeTab: $model.activeTab,
                    code: model.codeBinding,
                    statusText: model.statusText
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                ItemListPanel(
                    items: model.items,
                    selectedID: $model.selectedID,
                    rename: model.renameItem,
                    currentItem: model.currentItem
                )
                .frame(width: 320)
            }

            FooterBar(
                canRemove: model.items.count > 1 && model.currentItem != nil,
                onAdd: onAdd,
                onRemove: model.deleteSelectedItem
            )
        }
        .background(ConsoleTheme.bottomRed)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.black.opacity(0.22), lineWidth: 8)
        )
    }
}

private struct EditorPanel: View {
    let currentItem: StoredItem?
    @Binding var activeTab: EditorTab
    let code: (EditorTab) -> Binding<String>
    let statusText: String
    @State private var collapsedSections: Set<EditorTab> = []

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(EditorTab.allCases) { tab in
                    TabButton(tab: tab, isSelected: activeTab == tab) {
                        activeTab = tab
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text((currentItem?.name ?? "NO_ITEM").uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .italic()
                        .tracking(1.2)
                        .foregroundStyle(ConsoleTheme.textPrimary)
                        .lineLimit(1)

                    Text((currentItem?.type ?? "UNASSIGNED").uppercased())
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(ConsoleTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(statusText.uppercased())
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .tracking(1.8)
                    .foregroundStyle(ConsoleTheme.accentPink.opacity(0.8))
            }
            .padding(.horizontal, 4)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(ConsoleTheme.panelDeep.opacity(0.98))
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ConsoleTheme.shell, lineWidth: 4)

                VStack(spacing: 0) {
                    HStack {
                        Text("\(activeTab.rawValue).alki")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .italic()
                            .tracking(1.6)
                            .foregroundStyle(ConsoleTheme.accentPink.opacity(0.9))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(ConsoleTheme.panel)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                            .frame(height: 2)
                    }

                    if currentItem == nil {
                        ConsoleEmptyState(
                            title: "NO CONTENT",
                            message: "Select an item to edit HTML, CSS, JS, or ALL."
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if activeTab == .all {
                        AllTabEditor(code: code, collapsedSections: $collapsedSections)
                    } else {
                        TextEditor(text: code(activeTab))
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundStyle(ConsoleTheme.accentPink)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(ConsoleTheme.panelDeep.opacity(0.001))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(14)
    }
}

private struct AllTabEditor: View {
    let code: (EditorTab) -> Binding<String>
    @Binding var collapsedSections: Set<EditorTab>

    private let tabs: [EditorTab] = [.html, .css, .js]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(tabs) { tab in
                    EditorSectionCard(
                        tab: tab,
                        text: code(tab),
                        isCollapsed: collapsedSections.contains(tab),
                        toggle: { toggle(tab) }
                    )
                }
            }
            .padding(12)
        }
        .background(ConsoleTheme.panelDeep.opacity(0.001))
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
                        .foregroundStyle(ConsoleTheme.textSecondary)

                    Text(sectionTitle)
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .tracking(1.8)
                        .foregroundStyle(sectionColor)

                    Spacer()

                    Text(isCollapsed ? "EXPAND" : "MINIMIZE")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .tracking(1.4)
                        .foregroundStyle(ConsoleTheme.textSecondary.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(ConsoleTheme.panel)
            }
            .buttonStyle(.plain)

            if !isCollapsed {
                TextEditor(text: $text)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(sectionColor)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(ConsoleTheme.panelDeep.opacity(0.001))
            }
        }
        .background(ConsoleTheme.panel.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
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
            return ConsoleTheme.accentPink
        case .css:
            return Color.cyan.opacity(0.9)
        case .js:
            return Color.orange.opacity(0.9)
        case .all:
            return ConsoleTheme.textPrimary
        }
    }
}

private struct TabButton: View {
    let tab: EditorTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 16, weight: .black))
                Text(tab.title)
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .tracking(0.8)
            }
            .frame(width: 46, height: 46)
            .foregroundStyle(isSelected ? ConsoleTheme.bottomRed : ConsoleTheme.textPrimary)
            .background(isSelected ? ConsoleTheme.selectedLight : ConsoleTheme.topRed.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.10), lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.35 : 0), radius: 12, x: 0, y: 6)
            .scaleEffect(isSelected ? 1.04 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct ItemListPanel: View {
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
                        .foregroundStyle(ConsoleTheme.textMuted)
                    Text(currentItem.name.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(ConsoleTheme.textPrimary)
                        .lineLimit(1)
                    Text(currentItem.type.uppercased())
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(ConsoleTheme.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(ConsoleTheme.panelDeep.opacity(0.45))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(ConsoleTheme.shell)
                        .frame(height: 2)
                }
            }
        }
        .background(ConsoleTheme.panel)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(ConsoleTheme.shell)
                .frame(width: 4)
        }
    }
}

private struct ItemRow: View {
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
                .fill(isSelected ? ConsoleTheme.selectedLight : Color(red: 0.16, green: 0.16, blue: 0.16))

            Group {
                if isEditing {
                    TextField("", text: $draftName)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 8, weight: .black, design: .rounded))
                        .italic()
                        .textCase(.uppercase)
                        .foregroundStyle(isSelected ? ConsoleTheme.selectedText : ConsoleTheme.textPrimary)
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
                        .foregroundStyle(isSelected ? ConsoleTheme.selectedText : ConsoleTheme.textMuted)
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
    let canRemove: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.gray.opacity(0.7))

                Text("ALKI_SYS")
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .italic()
                    .tracking(1.6)
                    .foregroundStyle(Color.gray.opacity(0.88))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(ConsoleTheme.panel.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.gray.opacity(0.7))
            }

            Spacer()

            HStack(spacing: 10) {
                FooterActionButton(
                    color: ConsoleTheme.success,
                    shadow: Color(red: 0.07, green: 0.37, blue: 0.18),
                    systemImage: "plus"
                ) {
                    onAdd()
                }

                FooterActionButton(
                    color: ConsoleTheme.danger,
                    shadow: Color(red: 0.45, green: 0.10, blue: 0.12),
                    systemImage: "trash"
                ) {
                    onRemove()
                }
                .disabled(!canRemove)

                ZStack {
                    Circle()
                        .fill(ConsoleTheme.blue)
                    Circle()
                        .stroke(.white, lineWidth: 2)
                    Text("U")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(.white)
                }
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(Color.black.opacity(0.38))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(ConsoleTheme.shell)
                .frame(height: 2)
        }
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

private struct AddItemOverlay: View {
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
                                    .fill(ConsoleTheme.topRed.opacity(0.22))
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(ConsoleTheme.topRed.opacity(0.35), lineWidth: 1)
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(ConsoleTheme.topRed)
                            }
                            .frame(width: 40, height: 40)

                            Text("ADD NEW ITEM")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .italic()
                                .foregroundStyle(ConsoleTheme.textPrimary)
                        }

                        Spacer()

                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(ConsoleTheme.textSecondary)
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
                            .foregroundStyle(ConsoleTheme.topRed)

                        TextField("ENTER NAME...", text: $itemName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(ConsoleTheme.textPrimary)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(ConsoleTheme.panelDeep.opacity(0.96))
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
                        AngledModalButton(title: "CANCEL", foreground: ConsoleTheme.textMuted, background: ConsoleTheme.panel, action: onClose)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    Rectangle()
                        .fill(ConsoleTheme.topRed.opacity(0.5))
                        .frame(height: 8)
                }
                .background(ConsoleTheme.panel)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            }
            .padding(24)
            .frame(width: 460)
            .background(ConsoleTheme.bottomRed)
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
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .italic()
                .tracking(1.1)
                .foregroundStyle(ConsoleTheme.textPrimary)
            Text(message.uppercased())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1.1)
                .foregroundStyle(ConsoleTheme.textSecondary)
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

final class AppModel: ObservableObject {
    @Published var items: [StoredItem] = []
    @Published var selectedID: String?
    @Published var activeTab: EditorTab = .html
    @Published var statusText = "Ready"

    private let store: ItemStore
    private var pendingSaveWorkItem: DispatchWorkItem?

    var currentItem: StoredItem? {
        items.first(where: { $0.id == selectedID }) ?? items.first
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
            selectedID = items.first?.id
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
        pendingSaveWorkItem?.cancel()
        statusText = "Saving..."

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            do {
                let item = try self.store.updateStoredItem(id: id, patch: patch)
                if let index = self.items.firstIndex(where: { $0.id == id }) {
                    self.items[index] = item
                }
                self.statusText = "Saved"
            } catch {
                self.statusText = error.localizedDescription
            }
        }

        pendingSaveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    private func reload() {
        do {
            items = try store.loadItems()
            selectedID = items.first?.id
        } catch {
            statusText = error.localizedDescription
        }
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
}
