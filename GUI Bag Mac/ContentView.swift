import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var pendingNewItemName = ""
    @State private var isShowingAddModal = false
    @State private var pendingNewCollectionName = ""
    @State private var isShowingAddCollectionModal = false
    @State private var collectionPendingDeletion: PendingCollectionDeletion?
    @State private var itemPendingCollectionEdit: PendingItemCollectionEdit?
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
                    },
                    onAddCollection: {
                        pendingNewCollectionName = model.nextDefaultCollectionName()
                        isShowingAddCollectionModal = true
                    },
                    onDeleteCollectionRequested: { collection in
                        collectionPendingDeletion = PendingCollectionDeletion(id: collection.id, name: collection.name)
                    },
                    onEditItemCollectionRequested: { item in
                        itemPendingCollectionEdit = PendingItemCollectionEdit(
                            id: item.id,
                            itemName: item.name,
                            selectedCollectionID: item.collectionID
                        )
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

                if isShowingAddCollectionModal {
                    AddCollectionOverlay(
                        theme: theme,
                        collectionName: $pendingNewCollectionName,
                        onClose: {
                            isShowingAddCollectionModal = false
                            pendingNewCollectionName = ""
                        },
                        onConfirm: {
                            model.addCollection(named: pendingNewCollectionName)
                            isShowingAddCollectionModal = false
                            pendingNewCollectionName = ""
                        }
                    )
                    .transition(.opacity)
                    .zIndex(2)
                }

                if let pendingItemCollectionEdit = itemPendingCollectionEdit {
                    ItemCollectionOverlay(
                        theme: theme,
                        itemName: pendingItemCollectionEdit.itemName,
                        collections: model.collections,
                        initialCollectionID: pendingItemCollectionEdit.selectedCollectionID,
                        onClose: {
                            itemPendingCollectionEdit = nil
                        },
                        onConfirm: { collectionID in
                            model.assignItem(id: pendingItemCollectionEdit.id, toCollectionID: collectionID)
                            itemPendingCollectionEdit = nil
                        }
                    )
                    .transition(.opacity)
                    .zIndex(3)
                }
            }
        }
        .frame(minWidth: 1100, minHeight: 760)
        .background(WindowTransparencyConfigurator())
        .animation(.easeInOut(duration: 0.18), value: isShowingAddModal)
        .animation(.easeInOut(duration: 0.18), value: isShowingAddCollectionModal)
        .animation(.easeInOut(duration: 0.18), value: itemPendingCollectionEdit != nil)
        .alert(item: $collectionPendingDeletion) { pendingDeletion in
            Alert(
                title: Text("Delete Collection"),
                message: Text("Delete \"\(pendingDeletion.name)\"? Items in this collection will remain saved and move back to All Items."),
                primaryButton: .destructive(Text("Delete")) {
                    model.deleteCollection(id: pendingDeletion.id)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

private struct PendingCollectionDeletion: Identifiable {
    let id: String
    let name: String
}

private struct PendingItemCollectionEdit: Identifiable, Equatable {
    let id: String
    let itemName: String
    let selectedCollectionID: String?
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
    let onAddCollection: () -> Void
    let onDeleteCollectionRequested: (StoredCollection) -> Void
    let onEditItemCollectionRequested: (StoredItem) -> Void
    @State private var isShowingExpandedCanvas = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                CanvasToolbar(
                    model: model,
                    theme: theme,
                    showsExpandControl: true,
                    onExpand: { isShowingExpandedCanvas = true }
                )
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                GeometryReader { geo in
                    let leftWidth = geo.size.width * 4.0 / 12.0
                    let rightWidth = geo.size.width * 8.0 / 12.0
                    let displayHeight = geo.size.height * 1.8 / 2.8
                    let collectionsWidth = rightWidth * 1.2 / 3.2
                    let listWidth = rightWidth * 2.0 / 3.2

                    HStack(alignment: .top, spacing: 0) {
                        EditorPanel(
                            theme: theme,
                            currentItem: model.currentItem,
                            activeTab: $model.activeTab,
                            code: model.codeBinding,
                            statusText: model.statusText
                        )
                        .frame(width: leftWidth, height: geo.size.height)

                        VStack(spacing: 0) {
                            DisplayArea(model: model, theme: theme)
                                .frame(height: displayHeight)

                            HStack(spacing: 0) {
                                CollectionsBox(
                                    model: model,
                                    theme: theme,
                                    onAddCollection: onAddCollection,
                                    onDeleteCollectionRequested: onDeleteCollectionRequested
                                )
                                    .frame(width: collectionsWidth)

                                ItemListPanel(
                                    theme: theme,
                                    items: model.filteredItems,
                                    selectedID: $model.selectedID,
                                    rename: model.renameItem,
                                    duplicate: model.duplicateItem,
                                    delete: model.deleteItem,
                                    onEditCollection: onEditItemCollectionRequested
                                )
                                .frame(width: listWidth)
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .frame(width: rightWidth, height: geo.size.height)
                    }
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
        .padding(8)
        .background(theme.shell)
        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(theme.text.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.85), radius: 60, x: 0, y: 30)
        .sheet(isPresented: $isShowingExpandedCanvas) {
            ExpandedCanvasSheet(model: model, theme: theme)
        }
    }
}

private struct DisplayArea: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset

    var body: some View {
        ZStack {
            theme.topRed

            DotPatternOverlay()
                .opacity(0.10)

            if model.filteredItems.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(model.canvasBackdropMode.backgroundColor)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.stroke, lineWidth: 4)

                    ConsoleEmptyState(
                        theme: theme,
                        title: "NO CANVAS",
                        message: model.selectedCollectionID == nil ? "Add a tab to open a design canvas." : "This collection is empty. Add a new item here."
                    )
                }
                .padding(24)
            } else {
                CanvasCard(
                    model: model,
                    item: model.currentItem ?? model.filteredItems[0],
                    theme: theme,
                    zoomScale: model.canvasZoom,
                    isActive: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(18)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.stroke.opacity(0.85), lineWidth: 4)
        )
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 14)
    }
}

private struct CollectionsBox: View {
    @ObservedObject var model: AppModel
    let theme: ConsoleThemePreset
    let onAddCollection: () -> Void
    let onDeleteCollectionRequested: (StoredCollection) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("COLLECTIONS")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(theme.textSecondary)

                Spacer()

                Button(action: onAddCollection) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(theme.accent2)
                        .frame(width: 22, height: 22)
                        .background(theme.panelDeep.opacity(0.5), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(theme.panel2)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.stroke)
                    .frame(height: 2)
            }

            ScrollView {
                VStack(spacing: 6) {
                    CollectionRow(theme: theme, label: "ALL ITEMS", icon: "square.grid.2x2", isActive: model.selectedCollectionID == nil) {
                        model.selectCollection(nil)
                    }

                    ForEach(model.collections) { collection in
                        EditableCollectionRow(
                            theme: theme,
                            collection: collection,
                            isActive: model.selectedCollectionID == collection.id,
                            itemCount: model.items.filter { $0.collectionID == collection.id }.count,
                            onSelect: { model.selectCollection(collection.id) },
                            onRename: { model.renameCollection(id: collection.id, to: $0) },
                            onDelete: { onDeleteCollectionRequested(collection) }
                        )
                    }

                    if model.collections.isEmpty {
                        Text("NO CUSTOM SETS")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .tracking(1.2)
                            .foregroundStyle(theme.textSecondary.opacity(0.72))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.top, 8)
                    }
                }
                .padding(10)
            }
        }
        .background(theme.panel2)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(theme.stroke)
                .frame(width: 2)
        }
    }
}

private struct CollectionRow: View {
    let theme: ConsoleThemePreset
    let label: String
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isActive ? theme.accent2 : theme.textSecondary)
                    .frame(width: 20)

                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(isActive ? theme.textPrimary : theme.textMuted)

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isActive ? theme.panelDeep.opacity(0.65) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct EditableCollectionRow: View {
    let theme: ConsoleThemePreset
    let collection: StoredCollection
    let isActive: Bool
    let itemCount: Int
    let onSelect: () -> Void
    let onRename: (String) -> Void
    let onDelete: () -> Void

    @State private var isEditing = false
    @State private var draftName = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onSelect) {
                HStack(spacing: 10) {
                    Image(systemName: "folder")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isActive ? theme.accent2 : theme.textSecondary)
                        .frame(width: 18)

                    if isEditing {
                        TextField("", text: $draftName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(isActive ? theme.textPrimary : theme.textMuted)
                            .focused($isFocused)
                            .onSubmit(commitRename)
                            .onExitCommand(perform: cancelRename)
                            .onChange(of: isFocused) { focused in
                                if !focused && isEditing {
                                    commitRename()
                                }
                            }
                    } else {
                        Text(collection.name.uppercased())
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(isActive ? theme.textPrimary : theme.textMuted)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 6)

                    Text("\(itemCount)")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundStyle(isActive ? theme.accent2 : theme.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isActive ? theme.panelDeep.opacity(0.65) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .onTapGesture(count: 2, perform: beginEditing)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(theme.danger)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
    }

    private func beginEditing() {
        onSelect()
        draftName = collection.name
        isEditing = true
        DispatchQueue.main.async {
            isFocused = true
        }
    }

    private func commitRename() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != collection.name {
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

            if model.filteredItems.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(model.canvasBackdropMode.backgroundColor)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.stroke, lineWidth: 4)

                    ConsoleEmptyState(
                        theme: theme,
                        title: "NO CANVAS",
                        message: model.selectedCollectionID == nil ? "Add a tab to open a design canvas." : "This collection is empty. Add a new item here."
                    )
                }
            } else {
                CanvasCard(
                    model: model,
                    item: model.currentItem ?? model.filteredItems[0],
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

private func makeCanvasHTML(for item: StoredItem, backdropMode: CanvasBackdropMode) -> String {
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
            background: \(backdropMode.backgroundColor.cssHex);
            color: \(backdropMode.foregroundColor.cssHex);
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
        HStack(alignment: .center, spacing: 10) {
            HStack(spacing: 10) {
                if model.openTabs.count > 1 {
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
                                    } onClose: {
                                        model.closeTab(id: item.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                    .layoutPriority(1)
                } else {
                    Spacer(minLength: 0)
                }

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
    @ObservedObject var model: AppModel
    let item: StoredItem
    let theme: ConsoleThemePreset
    let zoomScale: CGFloat
    let isActive: Bool

    var body: some View {
        VStack(spacing: 0) {
            CanvasHeader(model: model, theme: theme, item: item, isActive: isActive, zoomScale: zoomScale)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(model.canvasBackdropMode.backgroundColor)

                CanvasRendererView(
                    html: makeCanvasHTML(for: item, backdropMode: model.canvasBackdropMode),
                    zoomScale: zoomScale
                )
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
    @ObservedObject var model: AppModel
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
                Button(action: model.toggleCanvasBackdropMode) {
                    Image(systemName: model.canvasBackdropMode.symbolName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(theme.accent2)
                        .frame(width: 24, height: 24)
                        .background(theme.accent2.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .help(model.canvasBackdropMode.toggleLabel)
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
    let onClose: () -> Void
    @State private var isHovered = false

    var body: some View {
        ZStack {
            Button(action: action) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(isSelected ? theme.accent2 : theme.textSecondary.opacity(0.35))
                        .frame(width: 6, height: 6)

                    Text(item.name)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .truncationMode(.tail)
                        .lineLimit(1)

                    trailingAccessory
                }
                .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary.opacity(0.82))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(backgroundShape)
            }
            .buttonStyle(.plain)

            if isHovered {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                            .frame(width: 16, height: 16)
                            .background(Color.black.opacity(isSelected ? 0.14 : 0.10), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 10)
                }
            }
        }
        .frame(maxWidth: 220)
        .zIndex(isSelected ? 1 : 0)
        .onHover { hovering in
            isHovered = hovering
        }
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

    @ViewBuilder
    private var trailingAccessory: some View {
        if isHovered {
            Color.clear
                .frame(width: 16, height: 16)
        } else if isSelected {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .black))
                .frame(width: 16, height: 16)
        } else {
            Color.clear
                .frame(width: 16, height: 16)
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

private struct EditorPanel: View {
    let theme: ConsoleThemePreset
    let currentItem: StoredItem?
    @Binding var activeTab: EditorTab
    let code: (EditorTab) -> Binding<String>
    let statusText: String
    @State private var collapsedSections: Set<EditorTab> = []

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    HStack(spacing: 6) {
                        ForEach(EditorTab.allCases) { tab in
                            TabButton(theme: theme, tab: tab, isSelected: activeTab == tab) {
                                activeTab = tab
                            }
                        }
                    }

                    Text(statusText.uppercased())
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .tracking(1.6)
                        .foregroundStyle(theme.accentPink.opacity(0.8))
                        .padding(.top, 2)
                        .padding(.leading, 6)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .padding(.top, 1)

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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 12)
        .padding(.top, 7)
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
                    .font(.system(size: 12, weight: .black))
                Text(tab.title)
                    .font(.system(size: 6, weight: .black, design: .rounded))
                    .tracking(0.7)
            }
            .frame(width: 34, height: 34)
            .foregroundStyle(isSelected ? theme.bottomRed : theme.textPrimary)
            .background(isSelected ? theme.selectedLight : theme.topRed.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? theme.accent : theme.text.opacity(0.10), lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.28 : 0), radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.03 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct ItemListPanel: View {
    let theme: ConsoleThemePreset
    let items: [StoredItem]
    @Binding var selectedID: String?
    let rename: (String, String) -> Void
    let duplicate: (String) -> Void
    let delete: (String) -> Void
    let onEditCollection: (StoredItem) -> Void

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
                            onRename: { rename(item.id, $0) },
                            onDuplicate: { duplicate(item.id) },
                            onDelete: { delete(item.id) },
                            onEditCollection: { onEditCollection(item) }
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 18)
            .padding(.bottom, 16)
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
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onEditCollection: () -> Void

    @State private var isEditing = false
    @State private var draftName = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            PolygonRowShape()
                .fill(isSelected ? theme.selectedLight : theme.panelDeep.opacity(0.82))

            HStack(spacing: 8) {
                Group {
                    if isEditing {
                        TextField("", text: $draftName)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.leading)
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
                Spacer(minLength: 0)

                Menu {
                    Button("Rename", action: beginEditing)
                    Button("Add to Collection", action: editCollection)
                    Button("Duplicate", action: duplicateItem)
                    Button("Delete", role: .destructive, action: deleteItem)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(isSelected ? theme.selectedText : theme.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(theme.topRed.opacity(isSelected ? 0.22 : 0.36), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .menuStyle(.borderlessButton)
                .buttonStyle(.plain)
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)
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

    private func duplicateItem() {
        onSelect()
        onDuplicate()
    }

    private func editCollection() {
        onSelect()
        onEditCollection()
    }

    private func deleteItem() {
        onSelect()
        onDelete()
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

private struct AddCollectionOverlay: View {
    let theme: ConsoleThemePreset
    @Binding var collectionName: String
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
                                    .fill(theme.accent2.opacity(0.18))
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(theme.accent2.opacity(0.30), lineWidth: 1)
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(theme.accent2)
                            }
                            .frame(width: 40, height: 40)

                            Text("ADD COLLECTION")
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
                        Text("COLLECTION NAME")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(1.8)
                            .foregroundStyle(theme.accent2)

                        TextField("ENTER NAME...", text: $collectionName)
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
                        AngledModalButton(title: "CONFIRM COLLECTION", foreground: .black, background: .white, action: confirm)
                        AngledModalButton(title: "CANCEL", foreground: theme.textMuted, background: theme.panel2, action: onClose)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    Rectangle()
                        .fill(theme.accent2.opacity(0.5))
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
        let trimmed = collectionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        collectionName = trimmed
        onConfirm()
    }
}

private struct ItemCollectionOverlay: View {
    let theme: ConsoleThemePreset
    let itemName: String
    let collections: [StoredCollection]
    let initialCollectionID: String?
    let onClose: () -> Void
    let onConfirm: (String?) -> Void

    @State private var selectedCollectionID: String?

    init(
        theme: ConsoleThemePreset,
        itemName: String,
        collections: [StoredCollection],
        initialCollectionID: String?,
        onClose: @escaping () -> Void,
        onConfirm: @escaping (String?) -> Void
    ) {
        self.theme = theme
        self.itemName = itemName
        self.collections = collections
        self.initialCollectionID = initialCollectionID
        self.onClose = onClose
        self.onConfirm = onConfirm
        _selectedCollectionID = State(initialValue: initialCollectionID)
    }

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
                                    .fill(theme.accent.opacity(0.18))
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(theme.accent.opacity(0.30), lineWidth: 1)
                                Image(systemName: "folder.badge.gearshape")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(theme.accent)
                            }
                            .frame(width: 40, height: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("ADD TO COLLECTION")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .italic()
                                    .foregroundStyle(theme.textPrimary)

                                Text(itemName.uppercased())
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .tracking(1.2)
                                    .foregroundStyle(theme.textSecondary)
                                    .lineLimit(1)
                            }
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

                    VStack(alignment: .leading, spacing: 10) {
                        Text("SELECT DESTINATION")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(1.8)
                            .foregroundStyle(theme.accent)

                        VStack(spacing: 8) {
                            CollectionSelectionRow(
                                theme: theme,
                                title: "ALL ITEMS",
                                subtitle: "REMOVE FROM CUSTOM COLLECTIONS",
                                isSelected: selectedCollectionID == nil
                            ) {
                                toggleSelection(nil)
                            }

                            if collections.isEmpty {
                                Text("NO COLLECTIONS YET")
                                    .font(.system(size: 10, weight: .black, design: .monospaced))
                                    .tracking(1.2)
                                    .foregroundStyle(theme.textSecondary.opacity(0.72))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(collections) { collection in
                                    CollectionSelectionRow(
                                        theme: theme,
                                        title: collection.name.uppercased(),
                                        subtitle: "TOGGLE MEMBERSHIP",
                                        isSelected: selectedCollectionID == collection.id
                                    ) {
                                        toggleSelection(collection.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    VStack(spacing: 12) {
                        AngledModalButton(title: "CONFIRM COLLECTION", foreground: .black, background: .white, action: confirm)
                        AngledModalButton(title: "CANCEL", foreground: theme.textMuted, background: theme.panel2, action: onClose)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    Rectangle()
                        .fill(theme.accent.opacity(0.5))
                        .frame(height: 8)
                }
                .background(theme.panel2)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            }
            .padding(24)
            .frame(width: 520)
            .background(theme.bottomRed)
            .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.55), radius: 40, x: 0, y: 20)
        }
    }

    private func toggleSelection(_ id: String?) {
        if selectedCollectionID == id {
            selectedCollectionID = nil
        } else {
            selectedCollectionID = id
        }
    }

    private func confirm() {
        onConfirm(selectedCollectionID)
    }
}

private struct CollectionSelectionRow: View {
    let theme: ConsoleThemePreset
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? theme.accent : theme.textSecondary)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? theme.panelDeep.opacity(0.92) : theme.panelDeep.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? theme.accent : theme.stroke.opacity(0.6), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
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

enum CanvasBackdropMode: Equatable {
    case dark
    case light

    var backgroundColor: Color {
        switch self {
        case .dark:
            return .black
        case .light:
            return .white
        }
    }

    var foregroundColor: Color {
        switch self {
        case .dark:
            return .white
        case .light:
            return .black
        }
    }

    var symbolName: String {
        switch self {
        case .dark:
            return "moon.fill"
        case .light:
            return "sun.max.fill"
        }
    }

    var toggleLabel: String {
        switch self {
        case .dark:
            return "Switch preview backdrop to white"
        case .light:
            return "Switch preview backdrop to black"
        }
    }

    mutating func toggle() {
        self = self == .dark ? .light : .dark
    }
}

final class AppModel: ObservableObject {
    @Published var collections: [StoredCollection] = []
    @Published var items: [StoredItem] = []
    @Published var selectedCollectionID: String? {
        didSet {
            guard selectedCollectionID != oldValue else { return }
            syncSelectionForCurrentCollection()
        }
    }
    @Published var selectedID: String? {
        didSet {
            guard selectedID != oldValue else { return }
            syncOpenTabs(previousSelectedID: oldValue, newSelectedID: selectedID)
        }
    }
    @Published private(set) var openTabIDs: [String] = []
    @Published var activeTab: EditorTab = .html
    @Published var canvasZoom: CGFloat = CanvasZoomPreset.oneHundred.scale
    @Published var canvasBackdropMode: CanvasBackdropMode = .dark
    @Published var statusText = "Ready"

    private let store: ItemStore
    private var pendingSave: PendingSave?

    private struct PendingSave {
        let id: String
        let patch: [String: String]
        let workItem: DispatchWorkItem
    }

    var currentItem: StoredItem? {
        filteredItems.first(where: { $0.id == selectedID }) ?? filteredItems.first
    }

    var filteredItems: [StoredItem] {
        guard let selectedCollectionID else { return items }
        return items.filter { $0.collectionID == selectedCollectionID }
    }

    var openTabs: [StoredItem] {
        let filteredItemIDs = Set(filteredItems.map(\.id))
        return openTabIDs.compactMap { id -> StoredItem? in
            guard filteredItemIDs.contains(id) else { return nil }
            return items.first(where: { $0.id == id })
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
                    collectionID: selectedCollectionID,
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

    func addCollection(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            let collection = try store.createCollection(named: trimmed)
            collections.append(collection)
            selectedCollectionID = collection.id
            statusText = "Added \(collection.name)"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func renameCollection(id: String, to value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = collections.firstIndex(where: { $0.id == id }) else { return }

        do {
            let collection = try store.updateCollection(id: id, name: trimmed)
            collections[index] = collection
            statusText = "Renamed collection"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func deleteCollection(id: String) {
        guard collections.contains(where: { $0.id == id }) else { return }

        do {
            try store.deleteCollection(id: id)
            collections.removeAll { $0.id == id }
            for index in items.indices where items[index].collectionID == id {
                items[index].collectionID = nil
            }
            if selectedCollectionID == id {
                selectedCollectionID = nil
            } else {
                syncSelectionForCurrentCollection()
            }
            statusText = "Deleted collection"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func deleteSelectedItem() {
        guard let id = currentItem?.id else { return }
        deleteItem(id: id)
    }

    func deleteItem(id: String) {
        guard items.contains(where: { $0.id == id }) else { return }

        flushPendingSave()

        let deletedName = items.first(where: { $0.id == id })?.name ?? "item"
        do {
            try store.deleteStoredItem(id: id)
            items.removeAll { $0.id == id }
            openTabIDs.removeAll { $0 == id }
            if openTabIDs.isEmpty, let firstID = filteredItems.first?.id ?? items.first?.id {
                openTabIDs = [firstID]
            }
            if selectedID == id {
                selectedID = openTabIDs.first ?? filteredItems.first?.id ?? items.first?.id
            } else {
                syncSelectionForCurrentCollection()
            }
            statusText = "Deleted \(deletedName)"
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

    func assignItem(id: String, toCollectionID collectionID: String?) {
        guard items.contains(where: { $0.id == id }) else { return }

        flushPendingSave()

        do {
            let item = try store.updateStoredItem(id: id, patch: ["collectionID": collectionID ?? ""])
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = item
            }

            if let selectedCollectionID, item.collectionID != selectedCollectionID {
                openTabIDs.removeAll { $0 == id }
                if selectedID == id {
                    syncSelectionForCurrentCollection()
                }
            }

            if let collectionID = item.collectionID,
               let collection = collections.first(where: { $0.id == collectionID }) {
                statusText = "Moved \(item.name) to \(collection.name)"
            } else {
                statusText = "Removed \(item.name) from collections"
            }
        } catch {
            statusText = error.localizedDescription
        }
    }

    func duplicateItem(id: String) {
        guard let sourceItem = items.first(where: { $0.id == id }) else { return }

        flushPendingSave()

        do {
            let duplicatedItem = try store.createStoredItem(
                payload: CreateItemPayload(
                    name: duplicatedItemName(from: sourceItem.name),
                    type: sourceItem.type,
                    collectionID: sourceItem.collectionID,
                    html: sourceItem.html,
                    css: sourceItem.css,
                    js: sourceItem.js,
                    all: sourceItem.all
                )
            )
            items.append(duplicatedItem)
            openTabIDs.append(duplicatedItem.id)
            selectedID = duplicatedItem.id
            statusText = "Duplicated \(sourceItem.name)"
        } catch {
            statusText = error.localizedDescription
        }
    }

    func selectCollection(_ id: String?) {
        selectedCollectionID = id
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
            collections = try store.loadCollections()
            items = try store.loadItems()
            let firstID = filteredItems.first?.id
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

    func closeTab(id: String) {
        guard let index = openTabIDs.firstIndex(of: id), openTabIDs.count > 1 else { return }

        openTabIDs.remove(at: index)

        guard selectedID == id else { return }

        let replacementIndex = min(index, openTabIDs.count - 1)
        selectedID = openTabIDs[replacementIndex]
    }

    private func syncOpenTabs(previousSelectedID: String?, newSelectedID: String?) {
        guard let newSelectedID else { return }
        guard filteredItems.contains(where: { $0.id == newSelectedID }) else { return }

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

    func toggleCanvasBackdropMode() {
        canvasBackdropMode.toggle()
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

    func nextDefaultCollectionName() -> String {
        let prefix = "Collection "
        let usedNumbers = collections.compactMap { collection -> Int? in
            guard collection.name.hasPrefix(prefix) else { return nil }
            return Int(collection.name.dropFirst(prefix.count))
        }
        return "\(prefix)\((usedNumbers.max() ?? 0) + 1)"
    }

    private func resolvedItemName(from name: String?) -> String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nextDefaultName() : trimmed
    }

    private func duplicatedItemName(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseName = trimmed.isEmpty ? nextDefaultName() : trimmed
        var candidate = "\(baseName) Copy"
        var copyNumber = 2

        while items.contains(where: { $0.name == candidate }) {
            candidate = "\(baseName) Copy \(copyNumber)"
            copyNumber += 1
        }

        return candidate
    }

    private func backupFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return "GUI-Bag-Backup-\(formatter.string(from: Date())).json"
    }

    private func syncSelectionForCurrentCollection() {
        let visibleItems = filteredItems

        if let selectedID, visibleItems.contains(where: { $0.id == selectedID }) {
            return
        }

        let firstID = visibleItems.first?.id
        openTabIDs = firstID.map { [$0] } ?? []
        selectedID = firstID
    }
}
