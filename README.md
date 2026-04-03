# Alki GUI Bag

GUI Bag is a native macOS app built with SwiftUI.

## Project

- Open [GUI Bag Mac.xcodeproj](/Volumes/ALKI%20SD/MACBOOK%20PRO%20STORAGE/ALKI%20Corp%20Dev/GUI%20Bag/GUI%20Bag%20Mac.xcodeproj) in Xcode.
- Build and run the `GUI Bag Mac` scheme.
- App data is stored locally in the app's `Application Support` directory.
- No web client, local server, or browser workflow is part of this project.

## Data Model

The local database stores:

- `schemaVersion`
- `nextId`
- `updatedAt`
- `items`

Each item contains saved UI code and metadata used by the macOS app.

## Notes

- Backups are exported and imported as JSON from the macOS app.
- Persistence is handled entirely in Swift.
