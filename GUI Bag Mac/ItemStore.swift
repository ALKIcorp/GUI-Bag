import Foundation

private let schemaVersion = 1

struct StoredItem: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var type: String
    var html: String
    var css: String
    var js: String
    var all: String?
    var createdAt: String?
    var updatedAt: String?
}

struct ItemDatabase: Codable {
    var schemaVersion: Int
    var nextId: Int
    var updatedAt: String
    var items: [StoredItem]
}

struct ItemBackup: Codable {
    var schemaVersion: Int
    var exportedAt: String
    var items: [StoredItem]
}

struct CreateItemPayload: Decodable {
    var name: String?
    var type: String?
    var html: String?
    var css: String?
    var js: String?
    var all: String?
}

struct UpdateItemPayload: Decodable {
    var id: String
    var patch: [String: String]
}

struct DeleteItemPayload: Decodable {
    var id: String
}

enum ItemStoreError: Error, LocalizedError {
    case invalidPayload
    case itemNotFound
    case invalidBackup

    var errorDescription: String? {
        switch self {
        case .invalidPayload:
            return "Invalid payload"
        case .itemNotFound:
            return "Item not found"
        case .invalidBackup:
            return "Backup file is invalid"
        }
    }
}

final class ItemStore {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let dbURL: URL

    init(fileManager: FileManager = .default) throws {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let supportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let appDirectory = supportDirectory
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.alkicorp.GUIBagMac", isDirectory: true)
        try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        self.dbURL = appDirectory.appendingPathComponent("db.json")

        try ensureDatabaseExists()
    }

    func listItemsResponse() throws -> [String: Any] {
        let db = try loadDatabase()
        return [
            "schemaVersion": db.schemaVersion,
            "items": try encodeItems(db.items),
            "updatedAt": db.updatedAt
        ]
    }

    func loadItems() throws -> [StoredItem] {
        try loadDatabase().items
    }

    func createItem(payload: CreateItemPayload) throws -> [String: Any] {
        let item = try createStoredItem(payload: payload)
        return ["item": try encodeItem(item)]
    }

    func createStoredItem(payload: CreateItemPayload) throws -> StoredItem {
        var db = try loadDatabase()
        let now = Self.utcNow()
        let item = StoredItem(
            id: String(db.nextId),
            name: payload.name?.isEmpty == false ? payload.name! : "NEW_CODE",
            type: payload.type?.isEmpty == false ? payload.type! : "UI",
            html: payload.html ?? "",
            css: payload.css ?? "",
            js: payload.js ?? "",
            all: payload.all ?? "",
            createdAt: now,
            updatedAt: nil
        )

        db.nextId += 1
        db.updatedAt = now
        db.items.append(item)
        try saveDatabase(db)

        return item
    }

    func updateItem(payload: UpdateItemPayload) throws -> [String: Any] {
        let item = try updateStoredItem(id: payload.id, patch: payload.patch)
        return ["item": try encodeItem(item)]
    }

    func updateStoredItem(id: String, patch: [String: String]) throws -> StoredItem {
        let allowedFields = Set(["name", "type", "html", "css", "js", "all"])
        let patch = patch.filter { allowedFields.contains($0.key) }
        guard !patch.isEmpty else {
            throw ItemStoreError.invalidPayload
        }

        var db = try loadDatabase()
        guard let index = db.items.firstIndex(where: { $0.id == id }) else {
            throw ItemStoreError.itemNotFound
        }

        var item = db.items[index]
        for (key, value) in patch {
            switch key {
            case "name":
                item.name = value
            case "type":
                item.type = value
            case "html":
                item.html = value
            case "css":
                item.css = value
            case "js":
                item.js = value
            case "all":
                item.all = value
            default:
                break
            }
        }

        item.updatedAt = Self.utcNow()
        db.items[index] = item
        db.updatedAt = item.updatedAt ?? db.updatedAt
        try saveDatabase(db)

        return item
    }

    func deleteItem(payload: DeleteItemPayload) throws -> [String: Any] {
        try deleteStoredItem(id: payload.id)
        return ["success": true]
    }

    func deleteStoredItem(id: String) throws {
        var db = try loadDatabase()
        let originalCount = db.items.count
        db.items.removeAll { $0.id == id }

        guard db.items.count != originalCount else {
            throw ItemStoreError.itemNotFound
        }

        db.updatedAt = Self.utcNow()
        try saveDatabase(db)
    }

    func exportBackup(to url: URL) throws {
        let db = try loadDatabase()
        let backup = ItemBackup(
            schemaVersion: db.schemaVersion,
            exportedAt: Self.utcNow(),
            items: db.items
        )
        let data = try encoder.encode(backup)
        try data.write(to: url, options: .atomic)
    }

    func importBackup(from url: URL) throws -> [StoredItem] {
        let data = try Data(contentsOf: url)
        let importedItems = try decodeBackupItems(from: data)

        var db = try loadDatabase()
        let now = Self.utcNow()
        let appendedItems = importedItems.map { importedItem in
            let item = StoredItem(
                id: String(db.nextId),
                name: importedItem.name.isEmpty ? "NEW_CODE" : importedItem.name,
                type: importedItem.type.isEmpty ? "UI Component" : importedItem.type,
                html: importedItem.html,
                css: importedItem.css,
                js: importedItem.js,
                all: importedItem.all ?? "",
                createdAt: importedItem.createdAt ?? now,
                updatedAt: importedItem.updatedAt
            )
            db.nextId += 1
            return item
        }

        db.items.append(contentsOf: appendedItems)
        db.updatedAt = now
        try saveDatabase(db)

        return appendedItems
    }

    private func ensureDatabaseExists() throws {
        guard !FileManager.default.fileExists(atPath: dbURL.path) else {
            let db = try loadDatabase()
            try saveDatabase(db)
            return
        }

        try saveDatabase(defaultDatabase())
    }

    private func loadDatabase() throws -> ItemDatabase {
        guard FileManager.default.fileExists(atPath: dbURL.path) else {
            return defaultDatabase()
        }

        do {
            let data = try Data(contentsOf: dbURL)
            let decoded = try decoder.decode(ItemDatabase.self, from: data)
            return normalize(decoded)
        } catch {
            return defaultDatabase()
        }
    }

    private func saveDatabase(_ database: ItemDatabase) throws {
        let normalized = normalize(database)
        let data = try encoder.encode(normalized)
        try data.write(to: dbURL, options: .atomic)
    }

    private func decodeBackupItems(from data: Data) throws -> [StoredItem] {
        if let backup = try? decoder.decode(ItemBackup.self, from: data) {
            return backup.items
        }

        if let database = try? decoder.decode(ItemDatabase.self, from: data) {
            return database.items
        }

        if let items = try? decoder.decode([StoredItem].self, from: data) {
            return items
        }

        throw ItemStoreError.invalidBackup
    }

    private func normalize(_ database: ItemDatabase) -> ItemDatabase {
        ItemDatabase(
            schemaVersion: database.schemaVersion > 0 ? database.schemaVersion : schemaVersion,
            nextId: max(database.nextId, 1),
            updatedAt: database.updatedAt.isEmpty ? Self.utcNow() : database.updatedAt,
            items: database.items
        )
    }

    private func defaultDatabase() -> ItemDatabase {
        ItemDatabase(
            schemaVersion: schemaVersion,
            nextId: 3,
            updatedAt: Self.utcNow(),
            items: [
                StoredItem(
                    id: "1",
                    name: "Super Potion",
                    type: "UI Component",
                    html: "<button class=\"potion-btn\">Heal 50HP</button>",
                    css: """
                    .potion-btn {
                      padding: 12px 24px;
                      background: #ff7675;
                      color: white;
                      border: 4px solid #d63031;
                      border-radius: 4px;
                      font-family: sans-serif;
                      font-weight: bold;
                      cursor: pointer;
                      box-shadow: 0 4px 0 #d63031;
                    }

                    .potion-btn:active {
                      transform: translateY(2px);
                      box-shadow: 0 2px 0 #d63031;
                    }
                    """,
                    js: "",
                    all: "",
                    createdAt: Self.utcNow(),
                    updatedAt: nil
                ),
                StoredItem(
                    id: "2",
                    name: "Lemonade",
                    type: "Beverage",
                    html: "<div class=\"lemon-loader\"></div>",
                    css: """
                    .lemon-loader {
                      width: 40px;
                      height: 40px;
                      border: 4px solid #ffe66d;
                      border-top: 4px solid transparent;
                      border-radius: 50%;
                      animation: spin 1s linear infinite;
                    }

                    @keyframes spin {
                      0% { transform: rotate(0deg); }
                      100% { transform: rotate(360deg); }
                    }
                    """,
                    js: "",
                    all: "",
                    createdAt: Self.utcNow(),
                    updatedAt: nil
                )
            ]
        )
    }

    private func encodeItem(_ item: StoredItem) throws -> [String: Any] {
        let data = try JSONEncoder().encode(item)
        return (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }

    private func encodeItems(_ items: [StoredItem]) throws -> [[String: Any]] {
        let data = try JSONEncoder().encode(items)
        return (try JSONSerialization.jsonObject(with: data) as? [[String: Any]]) ?? []
    }

    private static func utcNow() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
