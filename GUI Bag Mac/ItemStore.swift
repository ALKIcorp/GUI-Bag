import Foundation

private let schemaVersion = 2

struct StoredCollection: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var createdAt: String?
    var updatedAt: String?
}

struct StoredItem: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var type: String
    var collectionID: String?
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
    var collections: [StoredCollection]
    var items: [StoredItem]

    init(schemaVersion: Int, nextId: Int, updatedAt: String, collections: [StoredCollection], items: [StoredItem]) {
        self.schemaVersion = schemaVersion
        self.nextId = nextId
        self.updatedAt = updatedAt
        self.collections = collections
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        nextId = try container.decodeIfPresent(Int.self, forKey: .nextId) ?? 1
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
        collections = try container.decodeIfPresent([StoredCollection].self, forKey: .collections) ?? []
        items = try container.decodeIfPresent([StoredItem].self, forKey: .items) ?? []
    }
}

struct ItemBackup: Codable {
    var schemaVersion: Int
    var exportedAt: String
    var collections: [StoredCollection]
    var items: [StoredItem]

    init(schemaVersion: Int, exportedAt: String, collections: [StoredCollection], items: [StoredItem]) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.collections = collections
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 0
        exportedAt = try container.decodeIfPresent(String.self, forKey: .exportedAt) ?? ""
        collections = try container.decodeIfPresent([StoredCollection].self, forKey: .collections) ?? []
        items = try container.decodeIfPresent([StoredItem].self, forKey: .items) ?? []
    }
}

struct CreateItemPayload: Decodable {
    var name: String?
    var type: String?
    var collectionID: String?
    var html: String?
    var css: String?
    var js: String?
    var all: String?
}

enum ItemStoreError: Error, LocalizedError {
    case invalidPayload
    case itemNotFound
    case collectionNotFound
    case invalidBackup

    var errorDescription: String? {
        switch self {
        case .invalidPayload:
            return "Invalid payload"
        case .itemNotFound:
            return "Item not found"
        case .collectionNotFound:
            return "Collection not found"
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

    func loadItems() throws -> [StoredItem] {
        try loadDatabase().items
    }

    func loadCollections() throws -> [StoredCollection] {
        try loadDatabase().collections
    }

    func createStoredItem(payload: CreateItemPayload) throws -> StoredItem {
        var db = try loadDatabase()
        let now = Self.utcNow()
        let collectionID = normalizedCollectionID(payload.collectionID, collections: db.collections)
        let item = StoredItem(
            id: String(db.nextId),
            name: payload.name?.isEmpty == false ? payload.name! : "NEW_CODE",
            type: payload.type?.isEmpty == false ? payload.type! : "UI",
            collectionID: collectionID,
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

    func updateStoredItem(id: String, patch: [String: String]) throws -> StoredItem {
        let allowedFields = Set(["name", "type", "collectionID", "html", "css", "js", "all"])
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
            case "collectionID":
                item.collectionID = normalizedCollectionID(value, collections: db.collections)
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

    func createCollection(named name: String) throws -> StoredCollection {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ItemStoreError.invalidPayload
        }

        var db = try loadDatabase()
        let now = Self.utcNow()
        let collection = StoredCollection(
            id: String(db.nextId),
            name: trimmed,
            createdAt: now,
            updatedAt: nil
        )

        db.nextId += 1
        db.updatedAt = now
        db.collections.append(collection)
        try saveDatabase(db)

        return collection
    }

    func updateCollection(id: String, name: String) throws -> StoredCollection {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ItemStoreError.invalidPayload
        }

        var db = try loadDatabase()
        guard let index = db.collections.firstIndex(where: { $0.id == id }) else {
            throw ItemStoreError.collectionNotFound
        }

        db.collections[index].name = trimmed
        db.collections[index].updatedAt = Self.utcNow()
        db.updatedAt = db.collections[index].updatedAt ?? db.updatedAt
        try saveDatabase(db)

        return db.collections[index]
    }

    func deleteCollection(id: String) throws {
        var db = try loadDatabase()
        let originalCount = db.collections.count
        db.collections.removeAll { $0.id == id }

        guard db.collections.count != originalCount else {
            throw ItemStoreError.collectionNotFound
        }

        for index in db.items.indices where db.items[index].collectionID == id {
            db.items[index].collectionID = nil
            db.items[index].updatedAt = Self.utcNow()
        }

        db.updatedAt = Self.utcNow()
        try saveDatabase(db)
    }

    func exportBackup(to url: URL) throws {
        let db = try loadDatabase()
        let backup = ItemBackup(
            schemaVersion: db.schemaVersion,
            exportedAt: Self.utcNow(),
            collections: db.collections,
            items: db.items
        )
        let data = try encoder.encode(backup)
        try data.write(to: url, options: .atomic)
    }

    func importBackup(from url: URL) throws -> [StoredItem] {
        let data = try Data(contentsOf: url)
        let backup = try decodeBackup(from: data)
        let importedItems = backup.items

        var db = try loadDatabase()
        let now = Self.utcNow()
        var appendedItems = importedItems.map { importedItem in
            let item = StoredItem(
                id: String(db.nextId),
                name: importedItem.name.isEmpty ? "NEW_CODE" : importedItem.name,
                type: importedItem.type.isEmpty ? "UI Component" : importedItem.type,
                collectionID: importedItem.collectionID,
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

        let importedCollections = importedItems.reduce(into: Set<String>()) { result, item in
            if let collectionID = item.collectionID {
                result.insert(collectionID)
            }
        }

        for collection in backup.collections {
            guard importedCollections.contains(collection.id) else { continue }
            let remappedCollection = StoredCollection(
                id: String(db.nextId),
                name: collection.name.isEmpty ? "Collection" : collection.name,
                createdAt: collection.createdAt ?? now,
                updatedAt: collection.updatedAt
            )
            db.nextId += 1
            db.collections.append(remappedCollection)

            for index in appendedItems.indices where appendedItems[index].collectionID == collection.id {
                appendedItems[index].collectionID = remappedCollection.id
            }
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

    private func decodeBackup(from data: Data) throws -> ItemBackup {
        if let backup = try? decoder.decode(ItemBackup.self, from: data) {
            return backup
        }

        if let database = try? decoder.decode(ItemDatabase.self, from: data) {
            return ItemBackup(
                schemaVersion: database.schemaVersion,
                exportedAt: database.updatedAt,
                collections: database.collections,
                items: database.items
            )
        }

        if let items = try? decoder.decode([StoredItem].self, from: data) {
            return ItemBackup(
                schemaVersion: schemaVersion,
                exportedAt: Self.utcNow(),
                collections: [],
                items: items
            )
        }

        throw ItemStoreError.invalidBackup
    }

    private func normalize(_ database: ItemDatabase) -> ItemDatabase {
        let collections = database.collections.map { collection in
            StoredCollection(
                id: collection.id,
                name: collection.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Collection" : collection.name,
                createdAt: collection.createdAt,
                updatedAt: collection.updatedAt
            )
        }

        let validCollectionIDs = Set(collections.map(\.id))
        return ItemDatabase(
            schemaVersion: database.schemaVersion > 0 ? database.schemaVersion : schemaVersion,
            nextId: max(database.nextId, 1),
            updatedAt: database.updatedAt.isEmpty ? Self.utcNow() : database.updatedAt,
            collections: collections,
            items: database.items.map { item in
                var item = item
                if let collectionID = item.collectionID, !validCollectionIDs.contains(collectionID) {
                    item.collectionID = nil
                }
                return item
            }
        )
    }

    private func defaultDatabase() -> ItemDatabase {
        ItemDatabase(
            schemaVersion: schemaVersion,
            nextId: 3,
            updatedAt: Self.utcNow(),
            collections: [],
            items: [
                StoredItem(
                    id: "1",
                    name: "Super Potion",
                    type: "UI Component",
                    collectionID: nil,
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
                    collectionID: nil,
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

    private func normalizedCollectionID(_ collectionID: String?, collections: [StoredCollection]) -> String? {
        guard let collectionID, !collectionID.isEmpty else { return nil }
        return collections.contains(where: { $0.id == collectionID }) ? collectionID : nil
    }

    private static func utcNow() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
