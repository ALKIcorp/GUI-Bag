import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        VStack(spacing: 0) {
            HeaderBar(
                statusText: model.statusText,
                onAdd: model.addItem,
                onDelete: model.deleteSelectedItem
            )

            VSplitView {
                PreviewSection(item: model.currentItem)
                    .frame(minHeight: 280)

                HSplitView {
                    SidebarSection(
                        items: model.items,
                        selectedID: $model.selectedID,
                        rename: model.renameSelectedItem
                    )
                    .frame(minWidth: 220, idealWidth: 260, maxWidth: 320)

                    EditorSection(
                        currentItem: model.currentItem,
                        activeTab: $model.activeTab,
                        name: Binding(
                            get: { model.currentItem?.name ?? "" },
                            set: model.renameSelectedItem
                        ),
                        type: Binding(
                            get: { model.currentItem?.type ?? "" },
                            set: model.updateSelectedType
                        ),
                        code: model.codeBinding
                    )
                }
            }
        }
        .frame(minWidth: 1100, minHeight: 760)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct HeaderBar: View {
    let statusText: String
    let onAdd: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("GUI Bag")
                    .font(.title2.weight(.semibold))
                Text("Native macOS editor")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(statusText)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            Button("Delete", action: onDelete)
                .keyboardShortcut(.delete, modifiers: [])

            Button("Add Item", action: onAdd)
                .keyboardShortcut("n", modifiers: [.command])
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.thinMaterial)
    }
}

private struct PreviewSection: View {
    let item: StoredItem?

    var body: some View {
        Group {
            if let item {
                PreviewWebView(html: previewHTML(for: item))
            } else {
                EmptyStateView(
                    title: "No Item Selected",
                    systemImage: "square.stack",
                    message: "Create an item or pick one from the sidebar."
                )
            }
        }
        .background(Color.black.opacity(0.95))
    }

    private func previewHTML(for item: StoredItem) -> String {
        if let all = item.all, !all.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return all
        }

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
}

private struct SidebarSection: View {
    let items: [StoredItem]
    @Binding var selectedID: String?
    let rename: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            List(items, selection: $selectedID) { item in
                ItemRow(item: item, isSelected: item.id == selectedID)
                    .tag(item.id)
            }
            .listStyle(.sidebar)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Selected Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField(
                    "Item Name",
                    text: Binding(
                        get: { items.first(where: { $0.id == selectedID })?.name ?? "" },
                        set: rename
                    )
                )
                .textFieldStyle(.roundedBorder)
            }
            .padding(14)
        }
    }
}

private struct ItemRow: View {
    let item: StoredItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.name)
                .font(.headline)
                .lineLimit(1)
            Text(item.type)
                .font(.caption)
                .foregroundStyle(isSelected ? .secondary : .tertiary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

private struct EditorSection: View {
    let currentItem: StoredItem?
    @Binding var activeTab: EditorTab
    let name: Binding<String>
    let type: Binding<String>
    let code: (EditorTab) -> Binding<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if currentItem == nil {
                Spacer()
                EmptyStateView(
                    title: "No Content",
                    systemImage: "curlybraces",
                    message: "Select an item to edit its HTML, CSS, JS, or combined source."
                )
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Name", text: name)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Type")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Type", text: type)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Picker("Code Pane", selection: $activeTab) {
                        ForEach(EditorTab.allCases) { tab in
                            Text(tab.title).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextEditor(text: code(activeTab))
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08))
                        )
                }
            }
        }
        .padding(18)
    }
}

private struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
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
                    return item.all ?? ""
                }
            },
            set: { [self] in updateCurrentCode(tab: tab, value: $0) }
        )
    }

    func addItem() {
        do {
            let item = try store.createStoredItem(
                payload: CreateItemPayload(
                    name: nextDefaultName(),
                    type: "UI Component",
                    html: "",
                    css: "",
                    js: "",
                    all: ""
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
            updateSelectedField("all", value: value)
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

    private func nextDefaultName() -> String {
        let prefix = "UI Asset "
        let usedNumbers = items.compactMap { item -> Int? in
            guard item.name.hasPrefix(prefix) else { return nil }
            return Int(item.name.dropFirst(prefix.count))
        }
        return "\(prefix)\((usedNumbers.max() ?? 0) + 1)"
    }
}
