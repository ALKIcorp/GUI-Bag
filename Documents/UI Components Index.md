# UI Components Index

This document is a visual inventory of the app UI in `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag`. It is written as a recreation brief for another agent or a playground environment.

Important note: this project does not have a traditional standalone CSS app shell. The main UI is built in SwiftUI. The only literal CSS in the repo is user-authored component CSS rendered inside the canvas preview and the starter sample items.

## 1. Visual System Summary

### App Type

- Platform: macOS app
- Primary UI technology: SwiftUI
- Rendered preview surface: `WKWebView`
- Visual direction: dark console shell + high-contrast themed panels + glossy/glass tab controls + arcade/tooling aesthetics

### Core Visual Personality

- Large rounded shell with thick borders and heavy shadow
- Left editor pane styled like a code console
- Right display pane styled like a live preview dashboard
- Footer uses compact system controls with bright action colors
- Modal overlays are cinematic: dark scrim, thick rounded shells, oversized uppercase headings
- Typography mixes rounded system fonts, monospaced system fonts, and a branded splash font

### Fonts In Project

- `Helvetica Neue`
- `HelveticaNeueLTStd-Bd`
- Bundled file: `Helvetica Neue LT Std 75 Bold.otf`
- Present in repo but not clearly used in main UI views: `Micro Technic Extended Regular.ttf`
- Present in repo but not clearly used in main UI views: `Micro Technic Extended Bold.ttf`

### Global Shape Language

- Outer shell: rounded rectangles with `32` to `42` corner radius
- Panels/cards: rounded rectangles with `14` to `24` corner radius
- Small utility controls: rounded rectangles with `6`, `8`, `10`, or `12` corner radius
- Glass accessories: capsules
- Item rows: custom hex/polygon shape with angled left and right points
- Modal CTA buttons: custom angled trapezoid-like button shape

### Global Surface Language

- Main window uses transparent window chrome with a soft under-window glass effect
- Internal shell is opaque/dense and theme-driven
- Borders are used heavily:
  - thick outer strokes for shells/panels
  - subtle thin highlight strokes for smaller cards
- Shadows are strong and low-positioned
- Small repeated dividers: `1px`, `2px`, `4px`, `8px` bars

### Global Typography Patterns

- Section labels: tiny uppercase rounded system font with tracking
- Status text: monospaced uppercase
- Code surfaces: monospaced `TextEditor`
- Modal titles: large bold rounded italic
- Item row labels: tiny bold rounded italic uppercase
- Secondary info: small monospaced uppercase

### Global Interaction Language

- Most custom controls use `.buttonStyle(.plain)`
- Selected states are shown by:
  - accent stroke
  - brighter text
  - brighter fill
  - slight scale increase
  - shadow increase
  - small horizontal offset on selected list rows
- Hover state is mainly used on canvas tabs to reveal close buttons

## 2. Theme Tokens

All main application visuals come from `ConsoleThemePreset`.

### Theme Token Roles

- `appBg`: outer app/window background tone
- `panel`: main red/base panel tone
- `panel2`: secondary panel tone
- `accent`: primary bright accent / light contrast color
- `accent2`: secondary bright accent / highlight color
- `text`: primary foreground text
- `mutedText`: muted foreground text
- `stroke`: border/divider color
- `editorBg`: deepest dark editor/shell tone
- `previewBg`: bright preview-adjacent text/surface color
- `success`: green action color
- `danger`: destructive action color

### Token Aliases Used in Components

- `shell = editorBg`
- `topRed = panel2`
- `bottomRed = panel`
- `panelDeep = editorBg`
- `selectedLight = accent`
- `selectedText = panel`
- `textPrimary = text`
- `textSecondary = mutedText`
- `textMuted = mutedText`
- `accentPink = accent2`
- `blue = accent2`

### Theme Presets

- `Crimson Glass`
- `Obsidian Ice`
- `Royal Plum`
- `Emerald Noir`
- `Bronze Luxe`
- `Arctic Mint`
- `Graphite Orange`
- `Soft Sand`
- `Candy Core`
- `Ocean Terminal`
- `Acid Lime`
- `Midnight Rose`
- `Steel Blue Pro`
- `Ivory Cherry`
- `Neon Grape`

### Current Default Theme

- Default persisted selection falls back to `Crimson Glass`

### Full Preset Palette Values

#### Crimson Glass

- `appBg`: `#0A0A0D`
- `panel`: `#9E1633`
- `panel2`: `#7C1028`
- `accent`: `#F4F4F2`
- `accent2`: `#FF7A9E`
- `text`: `#FFF7FA`
- `mutedText`: `#D7B8C2`
- `stroke`: `#2A0F17`
- `editorBg`: `#050507`
- `previewBg`: `#F3F3F1`
- `success`: `#4DD08A`
- `danger`: `#FF4D6D`

#### Obsidian Ice

- `appBg`: `#05070A`
- `panel`: `#111827`
- `panel2`: `#1C2533`
- `accent`: `#DDF4FF`
- `accent2`: `#6FD3FF`
- `text`: `#F5FBFF`
- `mutedText`: `#9FB2C4`
- `stroke`: `#243041`
- `editorBg`: `#030508`
- `previewBg`: `#EAF6FF`
- `success`: `#52D9A6`
- `danger`: `#FF6B7A`

#### Royal Plum

- `appBg`: `#0D0812`
- `panel`: `#4B1E5A`
- `panel2`: `#341240`
- `accent`: `#F5D8FF`
- `accent2`: `#C77DFF`
- `text`: `#FFF6FF`
- `mutedText`: `#C9A8D5`
- `stroke`: `#221028`
- `editorBg`: `#07040A`
- `previewBg`: `#F8F2FF`
- `success`: `#49D18A`
- `danger`: `#FF5D87`

#### Emerald Noir

- `appBg`: `#06100D`
- `panel`: `#0F5C4A`
- `panel2`: `#0B4336`
- `accent`: `#D9FFF3`
- `accent2`: `#55E6B5`
- `text`: `#F3FFF9`
- `mutedText`: `#A6D3C5`
- `stroke`: `#103028`
- `editorBg`: `#040806`
- `previewBg`: `#ECFFF8`
- `success`: `#6EF0A6`
- `danger`: `#FF6A6A`

#### Bronze Luxe

- `appBg`: `#110C08`
- `panel`: `#7A4A2C`
- `panel2`: `#5B351E`
- `accent`: `#F8E7D8`
- `accent2`: `#D9A066`
- `text`: `#FFF8F1`
- `mutedText`: `#D0B49C`
- `stroke`: `#2B1A10`
- `editorBg`: `#080503`
- `previewBg`: `#FFF5EC`
- `success`: `#63D79B`
- `danger`: `#FF6E5B`

#### Arctic Mint

- `appBg`: `#081012`
- `panel`: `#A7F0E9`
- `panel2`: `#74D9D0`
- `accent`: `#0E2A2C`
- `accent2`: `#E8FFFD`
- `text`: `#F8FFFF`
- `mutedText`: `#A7C7C8`
- `stroke`: `#204245`
- `editorBg`: `#0A1415`
- `previewBg`: `#F2FFFE`
- `success`: `#42D392`
- `danger`: `#FF647C`

#### Graphite Orange

- `appBg`: `#0B0B0C`
- `panel`: `#1A1A1E`
- `panel2`: `#24242A`
- `accent`: `#FF9F43`
- `accent2`: `#FFD7A8`
- `text`: `#FFF8F0`
- `mutedText`: `#B7ADA2`
- `stroke`: `#35353D`
- `editorBg`: `#050506`
- `previewBg`: `#FFF4E8`
- `success`: `#59D68D`
- `danger`: `#FF5A5F`

#### Soft Sand

- `appBg`: `#15120E`
- `panel`: `#D7C2A4`
- `panel2`: `#B89E7B`
- `accent`: `#5B4330`
- `accent2`: `#FFF4E6`
- `text`: `#FFFDF8`
- `mutedText`: `#C7BAAA`
- `stroke`: `#6E5B46`
- `editorBg`: `#0E0A07`
- `previewBg`: `#FFF9F0`
- `success`: `#6BCB95`
- `danger`: `#E96A5F`

#### Candy Core

- `appBg`: `#120914`
- `panel`: `#FF4FA3`
- `panel2`: `#D92C82`
- `accent`: `#FFF0F7`
- `accent2`: `#7DF9FF`
- `text`: `#FFF8FC`
- `mutedText`: `#E3B6CB`
- `stroke`: `#4A1830`
- `editorBg`: `#09040A`
- `previewBg`: `#FFF5FA`
- `success`: `#54E29B`
- `danger`: `#FF5C8A`

#### Ocean Terminal

- `appBg`: `#06131A`
- `panel`: `#0E7490`
- `panel2`: `#125D73`
- `accent`: `#D6F6FF`
- `accent2`: `#7CE2FF`
- `text`: `#F3FCFF`
- `mutedText`: `#A7C9D1`
- `stroke`: `#123543`
- `editorBg`: `#040A0D`
- `previewBg`: `#EEFBFF`
- `success`: `#51D9A4`
- `danger`: `#FF6B6B`

#### Acid Lime

- `appBg`: `#0A0D05`
- `panel`: `#7FBF00`
- `panel2`: `#5F9300`
- `accent`: `#F6FFE0`
- `accent2`: `#D7FF70`
- `text`: `#FAFFF0`
- `mutedText`: `#C4D49B`
- `stroke`: `#28330E`
- `editorBg`: `#060803`
- `previewBg`: `#F9FFF0`
- `success`: `#64E08C`
- `danger`: `#FF5D5D`

#### Midnight Rose

- `appBg`: `#09080C`
- `panel`: `#6B1F3A`
- `panel2`: `#4C1628`
- `accent`: `#FFDCE8`
- `accent2`: `#FF8FB1`
- `text`: `#FFF7FA`
- `mutedText`: `#D2ACB8`
- `stroke`: `#241119`
- `editorBg`: `#050407`
- `previewBg`: `#FFF2F7`
- `success`: `#57D58F`
- `danger`: `#FF5878`

#### Steel Blue Pro

- `appBg`: `#0A0E14`
- `panel`: `#2B4257`
- `panel2`: `#1E3142`
- `accent`: `#E4F1FF`
- `accent2`: `#8DBDFF`
- `text`: `#F7FAFF`
- `mutedText`: `#AAB7C6`
- `stroke`: `#24313F`
- `editorBg`: `#06090D`
- `previewBg`: `#F0F7FF`
- `success`: `#5ED39A`
- `danger`: `#FF6D6D`

#### Ivory Cherry

- `appBg`: `#1A1516`
- `panel`: `#F6F1EC`
- `panel2`: `#E6D8D1`
- `accent`: `#9F1D35`
- `accent2`: `#FFB3C1`
- `text`: `#1C1718`
- `mutedText`: `#7B6D6F`
- `stroke`: `#C9B4B0`
- `editorBg`: `#0F0B0C`
- `previewBg`: `#FFFDFC`
- `success`: `#2FAF73`
- `danger`: `#D6455D`

#### Neon Grape

- `appBg`: `#08050D`
- `panel`: `#2C114A`
- `panel2`: `#1D0B33`
- `accent`: `#B517FF`
- `accent2`: `#6EF3FF`
- `text`: `#FAF4FF`
- `mutedText`: `#BBA9CB`
- `stroke`: `#2F1E42`
- `editorBg`: `#040208`
- `previewBg`: `#F8F1FF`
- `success`: `#4DDB94`
- `danger`: `#FF5A7A`

## 3. Window And App-Level Surfaces

### Launch Root

- Purpose: shows splash screen, then swaps to main app
- Transition: opacity fade
- Splash duration: about `1800ms`
- Main window default size: `1280 x 820`
- Minimum main content size: `1100 x 760`

### Window Transparency

- Window background is clear
- Title bar appears transparent
- Window content view background is clear
- Window shadow remains enabled
- Main app sits over a transparent/glass macOS window base

### Window Background Glass

- Backdrop view: `NSVisualEffectView`
- Material: `underWindowBackground`
- Blend mode: `behindWindow`
- Alpha: `0.24`
- Additional themed tint: `theme.appBg` at `0.18` alpha

## 4. Brand Assets

### Asset Sets

- `GUIBagSplashIcon`
- `GUIBagTextLogo`
- `AppIcon.appiconset`

### Splash Screen Composition

- Large centered logo image
  - size: `220 x 220`
  - shadow: black `0.18`, radius `24`, y `15`
- Wordmark image
  - width: `520`
- Attribution line:
  - `"by "` in `Helvetica Neue` size `23`
  - `"Alki Corp."` in bold custom font size `23`
  - color: white at `0.9`
- Rights line:
  - bold custom font size `17`
  - white at `0.8`
- Overall splash frame: `784 x 504`

### About Window

- Size: `360 x 330`
- Background: vertical gradient
  - top: `windowBackgroundColor`
  - bottom: `controlBackgroundColor`
- App icon:
  - `84 x 84`
  - rounded rectangle clip radius `18`
  - shadow: black `0.16`, radius `10`, y `6`
- Text stack:
  - app name `24 semibold`
  - version `14 medium`
  - metadata rows `13`

## 5. Main Layout Blueprint

### Outer Shell

- Content width clamps to `960...1380` depending on window size
- Content height clamps to `700...920`
- Outer wrapper:
  - padding `8`
  - background `theme.shell`
  - corner radius `42`
  - thin highlight stroke `1px` at `theme.text.opacity(0.05)`
  - shadow: black `0.85`, radius `60`, y `30`

### Inner Shell

- Background: `theme.bottomRed`
- Corner radius: `32`
- Outer stroke: `8px` using `theme.stroke.opacity(0.85)`

### Internal Region Split

- Top toolbar at full width
- Main body split into:
  - left editor: `4/12` width
  - right content area: `8/12` width
- Right content area split vertically:
  - top display area: `1.8 / 2.8` of right column height
  - bottom row: collections + item list
- Bottom right row split horizontally:
  - collections: `1.2 / 3.2`
  - item list: `2.0 / 3.2`
- Footer anchored at bottom

## 6. Component Inventory

Each subsection below is meant to be independently reusable.

### 6.1 `ConsoleWindow`

- Role: master application shell
- Contains:
  - `CanvasToolbar`
  - `EditorPanel`
  - `DisplayArea`
  - `CollectionsBox`
  - `ItemListPanel`
  - `FooterBar`
- Visual identity:
  - thick rounded console chassis
  - strong contrast between deep shell and brighter internal theme panels

### 6.2 `DisplayArea`

- Role: upper-right live preview region
- Base fill: `theme.topRed`
- Decorative texture: `DotPatternOverlay` at `0.10` opacity
- Empty state:
  - inner card radius `22`
  - fill uses current preview backdrop mode
  - `4px` stroke in `theme.stroke`
  - padded by `24`
- Populated state:
  - contains `CanvasCard`
  - padded by `18`
- Outer shell:
  - radius `24`
  - stroke `4px` using `theme.stroke.opacity(0.85)`
  - shadow black `0.25`, radius `18`, y `14`

### 6.3 `DotPatternOverlay`

- Role: decorative halftone/dot matrix field
- Pattern logic:
  - dot every `8px`
  - each dot size `2px`
  - black circular dots
- Interaction: non-hit-testable
- Use case: gives the display region a printed-tech texture

### 6.4 `CanvasToolbar`

- Role: top bar above preview
- Layout:
  - left: open-tab rail and add-tab control
  - center divider: `1px x 30px`
  - right: zoom cluster and optional expand control
- Spacing: `10`
- Appearance: compact, floating, glass-influenced control row

### 6.5 `GlassTabRail`

- Role: glass container for open canvas tabs
- Modern mode:
  - `.glassEffect(.regular.tint(theme.accent.opacity(0.10)))`
  - corner radius `20`
- Fallback mode:
  - `.ultraThinMaterial`
  - rounded rectangle radius `20`
- Border:
  - `1px`
  - `theme.text.opacity(0.08)`

### 6.6 `CanvasTabButton`

- Role: open document/tab pill
- Width cap: `220`
- Internal structure:
  - left status dot `6 x 6`
  - tab label
  - trailing checkmark space or hover-close space
- Typography:
  - size `11`
  - selected: semibold rounded
  - unselected: medium rounded
- Selected state:
  - glass background via `GlassTabAccessory`
  - brighter text
  - checkmark icon size `9`
  - raised z-index
- Unselected state:
  - black fill at `0.10`
  - `1px` stroke at `theme.text.opacity(0.05)`
- Hover state:
  - reveals circular `xmark` close button
  - close button size `16 x 16`

### 6.7 `GlassTabAccessory`

- Role: shared glass/capsule micro-surface
- Shape: capsule
- Modern mode:
  - interactive glass effect
  - tinted with `theme.accent.opacity(prominence)`
- Fallback:
  - `.ultraThinMaterial`
  - capsule border `1px` at `theme.text.opacity(0.10)`
- Used by:
  - zoom cluster
  - add tab button
  - expanded canvas button
  - selected tab backgrounds

### 6.8 `CanvasAddTabButton`

- Role: add new canvas/item shortcut
- Container: `GlassTabAccessory`
- Icon: `plus`
- Frame: `30 x 30`
- Icon color: `theme.textSecondary`
- Prominence: `0.14`

### 6.9 `CanvasControlCluster`

- Role: zoom and expansion controls
- Includes:
  - zoom out button
  - zoom preset menu
  - zoom in button
  - optional expand button
- Shared typography:
  - size `12`, semibold for icon row
- Zoom menu label:
  - rounded semibold size `10`
  - min width `42`

### 6.10 `CanvasCard`

- Role: framed live preview card
- Structure:
  - `CanvasHeader`
  - preview body with inset web view
- Background: `theme.editorBg.opacity(0.92)`
- Outer radius: `24`
- Active stroke:
  - `3px`
  - `theme.accent2.opacity(0.75)`
- Inactive stroke:
  - `2px`
  - `theme.stroke`
- Active shadow:
  - black `0.24`
  - radius `18`
  - y `12`
- Preview well:
  - base radius `20`
  - inner web content clipped to radius `16`
  - internal padding `8`
  - outer preview padding `10`

### 6.11 `CanvasHeader`

- Role: top strip for preview metadata and theme toggle
- Background: `theme.panel2.opacity(0.96)`
- Padding: horizontal `14`, vertical `12`
- Leading icon:
  - `rectangle.on.rectangle`
  - frame `24 x 24`
  - accent chip background with radius `8`
- Primary text:
  - item name
  - rounded semibold size `11`
- Secondary text:
  - `"Canvas • XX%"`
  - monospaced medium size `9`
- Right control:
  - backdrop mode toggle
  - same `24 x 24` accent chip style

### 6.12 `CanvasWorkspace`

- Role: reusable preview workspace used in expanded canvas mode
- Layout:
  - toolbar
  - canvas or empty state
- Vertical spacing: `18`
- Shadow: black `0.25`, radius `18`, y `14`

### 6.13 `ExpandedCanvasSheet`

- Role: large sheet for full-size preview work
- Min frame: `1200 x 760`
- Background layers:
  - `WindowBackgroundGlass`
  - diagonal linear gradient from `theme.appBg.opacity(0.96)` to `theme.panel2.opacity(0.82)`
- Header:
  - label `EXPANDED CANVAS`
  - size `12`, black rounded, tracking `1.6`
  - trailing standard bordered prominent `Close` button
- Content padding: `24`

### 6.14 `EditorPanel`

- Role: left code-editor column
- Top region:
  - row of `TabButton`s
  - status text in monospaced uppercase
- Main shell:
  - rounded rectangle radius `18`
  - fill `theme.panelDeep.opacity(0.98)`
  - stroke `4px` in `theme.stroke`
- Top file bar:
  - label like `html.alki`
  - monospaced black italic size `9`
  - accent pink tone
  - background `theme.panel2`
  - bottom black divider `2px` at `0.7` opacity
- Editor content:
  - empty state or code editor
  - editor text size `12` monospaced
- Outer padding:
  - horizontal `12`
  - top `7`
  - bottom `10`

### 6.15 `TabButton`

- Role: compact editor tab switcher for `HTML`, `CSS`, `JS`, `ALL`
- Size: `34 x 34`
- Layout:
  - top icon
  - tiny text label
- Typography:
  - icon size `12`, black
  - label size `6`, rounded black
- Selected state:
  - foreground `theme.bottomRed`
  - background `theme.selectedLight`
  - `2px` stroke in `theme.accent`
  - shadow black `0.28`, radius `8`, y `4`
  - scale `1.03`
- Unselected state:
  - foreground `theme.textPrimary`
  - background `theme.topRed.opacity(0.35)`
  - subtle stroke `theme.text.opacity(0.10)`

### 6.16 `AllTabEditor`

- Role: stacked all-in-one editor for HTML/CSS/JS
- Container: vertical scroll view
- Inner spacing: `12`
- Padding: `12`
- Contains three `EditorSectionCard`s

### 6.17 `EditorSectionCard`

- Role: collapsible code block card inside ALL tab
- Outer shell:
  - background `theme.panel2.opacity(0.45)`
  - corner radius `14`
  - `1px` border at `theme.text.opacity(0.08)`
- Header:
  - plain button
  - background `theme.panel2`
  - chevron icon size `10`
  - title size `9` monospaced black
  - action label size `8` monospaced
- Expanded content:
  - `TextEditor`
  - size `12` monospaced
  - min height `150`
  - padding `12`
- Section colors:
  - HTML: `theme.accentPink`
  - CSS: `theme.accent`
  - JS: `theme.text`

### 6.18 `CollectionsBox`

- Role: bottom-right-left sidebar of collection filters
- Header:
  - title `COLLECTIONS`
  - size `9`, rounded black, tracking `1.8`
  - add button on right
- Add button:
  - icon `plus`
  - size `22 x 22`
  - icon color `theme.accent2`
  - dark rounded chip radius `8`
- Header background: `theme.panel2`
- Header bottom divider: `2px` `theme.stroke`
- Body:
  - scrollable list
  - content padding `10`
  - row spacing `6`
- Panel border:
  - trailing divider `2px` in `theme.stroke`

### 6.19 `CollectionRow`

- Role: simple selectable collection filter row
- Used for:
  - `ALL ITEMS`
  - `FAVORITES`
- Layout:
  - leading icon width `20`
  - label
  - optional count
- Typography:
  - label size `9`, rounded black
  - count size `8`, monospaced black
- Padding: horizontal `10`, vertical `8`
- Active background:
  - `theme.panelDeep.opacity(0.65)`
  - radius `10`

### 6.20 `EditableCollectionRow`

- Role: custom collection row with rename and delete affordances
- Left side behaves like `CollectionRow`
- Right side:
  - standalone trash button
  - icon size `10`
  - frame `24 x 24`
  - color `theme.danger`
- Inline edit state:
  - plain `TextField`
  - rounded black size `9`
- Active row styling matches `CollectionRow`

### 6.21 `ItemListPanel`

- Role: item list panel to the right of collections
- Structure:
  - scroll view
  - lazy stack of `ItemRow`s
- Padding:
  - horizontal `8`
  - top `18`
  - bottom `16`
- Background: `theme.panel2`
- Leading divider: `4px` in `theme.stroke`

### 6.22 `ItemRow`

- Role: stylized asset/component row
- Base shape: `PolygonRowShape`
- Height: `36`
- Padding:
  - left `16`
  - right `12`
- Selected state:
  - fill `theme.selectedLight`
  - text color `theme.selectedText`
  - shadow black `0.18`, radius `6`, y `4`
  - x offset `4`
- Unselected state:
  - fill `theme.panelDeep.opacity(0.82)`
  - muted text
- Label:
  - rounded black size `8`
  - italic
  - uppercase look
- Overflow menu:
  - icon `ellipsis`
  - size `24 x 24`
  - chip background `theme.topRed` with varying opacity
- Menu actions:
  - Rename
  - Add/Remove Favorite
  - Add to Collection
  - Duplicate
  - Delete

### 6.23 `PolygonRowShape`

- Role: reusable angular list-row silhouette
- Geometry:
  - horizontal inset = `5%` of width
  - center points on both left and right edges
- Visual result:
  - elongated hexagon / cartridge shape

### 6.24 `FooterBar`

- Role: lower utility/control bar
- Height: `56`
- Horizontal padding: `18`
- Background: `theme.appBg.opacity(0.72)`
- Top divider: `2px` `theme.stroke`
- Left cluster:
  - chevron left
  - `ALKI_SYS` label chip
  - chevron right
- Right cluster:
  - add button
  - delete button
  - settings pill

### 6.25 `FooterActionButton`

- Role: small square action button for add/remove
- Size: `28 x 28`
- Shape: rounded rectangle radius `6`
- Bottom faux-shadow bar:
  - height `3`
  - offset y `2`
- Icon:
  - white
  - size `13`, black weight
- Color driven by token:
  - success green for add
  - danger red for remove

### 6.26 `ThemeSettingsPopover`

- Role: settings popover for theme and backups
- Background: `theme.editorBg`
- Padding: `14`
- Layout:
  - title
  - theme preset scroll list
  - backup action section
- Theme list frame: `320 x 360`

### 6.27 Theme Preset Card

- Role: selectable card inside settings popover
- Background: `preset.panel`
- Radius: `14`
- Stroke:
  - selected: `preset.accent2`, `2px`
  - unselected: `preset.stroke`, `2px`
- Internal layout:
  - preset name
  - optional checkmark circle
  - row of 5 color swatches
- Padding: `12`

### 6.28 `ThemeSwatch`

- Role: tiny palette indicator
- Shape: capsule
- Height: `10`

### 6.29 `BackupActionButton`

- Role: rectangular CTA in settings popover
- Height: `34`
- Shape: rounded rectangle radius `12`
- Layout:
  - icon size `11`
  - title size `8`, rounded black
- Variants:
  - save backup: success fill, dark text
  - load backup: accent2 fill, previewBg text

### 6.30 `AddItemOverlay`

- Role: modal to create new item
- Full-screen scrim:
  - black `0.82`
- Outer shell:
  - width `460`
  - background `theme.bottomRed`
  - radius `38`
  - white stroke `1px` at `0.05`
  - shadow black `0.55`, radius `40`, y `20`
  - padding `24`
- Inner card:
  - background `theme.panel2`
  - radius `34`
- Header:
  - icon chip `40 x 40`
  - icon `shippingbox.fill`
  - icon color `theme.topRed`
  - title size `22`, rounded black, italic
- Form label:
  - size `10`
  - rounded black
  - tracking `1.8`
  - color `theme.topRed`
- Input field:
  - monospaced medium size `14`
  - padding `16`
  - dark fill `theme.panelDeep.opacity(0.96)`
  - rounded rectangle radius `18`
  - dark stroke `2px`
- Bottom accent strip:
  - `8px` high
  - `theme.topRed.opacity(0.5)`

### 6.31 `AddCollectionOverlay`

- Same structure as `AddItemOverlay`
- Differences:
  - icon: `folder.badge.plus`
  - accent color: `theme.accent2`
  - label text: `COLLECTION NAME`
  - bottom strip uses `theme.accent2.opacity(0.5)`

### 6.32 `ItemCollectionOverlay`

- Role: assign an item to a collection
- Same modal shell family as add modals
- Width: `520`
- Header icon:
  - `folder.badge.gearshape`
  - accent color `theme.accent`
- Header includes selected item name in small monospaced uppercase
- Body consists of stacked `CollectionSelectionRow`s
- Empty state text:
  - `NO COLLECTIONS YET`
  - monospaced size `10`
- Bottom strip uses `theme.accent.opacity(0.5)`

### 6.33 `CollectionSelectionRow`

- Role: selectable option row inside assignment modal
- Horizontal layout:
  - checkmark/circle icon
  - title + subtitle stack
  - spacer
- Typography:
  - title size `11`, rounded black
  - subtitle size `8`, monospaced bold
- Padding:
  - horizontal `14`
  - vertical `12`
- Background:
  - selected `theme.panelDeep.opacity(0.92)`
  - unselected `theme.panelDeep.opacity(0.72)`
- Border:
  - selected `theme.accent`, `2px`
  - unselected `theme.stroke.opacity(0.6)`, `2px`
- Radius: `16`

### 6.34 `AngledModalButton`

- Role: modal CTA button
- Height: `48`
- Full-width
- Typography:
  - rounded black size `13`
  - italic
- Shape: `AngledButtonShape`
- Variants used:
  - white confirm button with black text
  - theme panel cancel button with muted text

### 6.35 `AngledButtonShape`

- Role: custom asymmetrical button silhouette
- Geometry:
  - top edge starts inset by `5%`
  - top-right full width
  - bottom-right pulled inward by `5%`
  - bottom-left full width
- Visual result:
  - skewed/trapezoid action bar

### 6.36 `ConsoleEmptyState`

- Role: reusable no-content placeholder
- Layout: vertical stack, spacing `8`
- Title:
  - size `13`, rounded black, italic
  - tracking `1.1`
- Message:
  - size `9`, monospaced bold
  - uppercase display
  - centered
- Padding: `24`

## 7. Embedded Preview Surface

### `CanvasRendererView`

- Technology: `WKWebView`
- Background drawing disabled
- Developer extras enabled
- Magnification controlled by app state
- HTML reloaded only when content changes

### Preview HTML Wrapper

Every item preview is wrapped in a generated HTML document with:

- `html, body`
  - `margin: 0`
  - `min-height: 100%`
  - `background`: current backdrop mode (`black` or `white`)
  - `color`: inverse foreground
  - `font-family: -apple-system, BlinkMacSystemFont, sans-serif`
- `body`
  - `display: flex`
  - `align-items: center`
  - `justify-content: center`
  - `padding: 24px`
  - `box-sizing: border-box`

Then the app injects:

- `item.css`
- `item.html`
- `item.js`

### Preview Backdrop Modes

- Dark mode:
  - background `#000000`
  - foreground `#FFFFFF`
  - icon: `moon.fill`
- Light mode:
  - background `#FFFFFF`
  - foreground `#000000`
  - icon: `sun.max.fill`

## 8. Default Starter Assets Stored In Data

These are not SwiftUI components; they are starter preview items stored by the app.

### Starter Item 1: `Super Potion`

- HTML:
  - button with class `.potion-btn`
- CSS behavior:
  - padding `12px 24px`
  - background `#ff7675`
  - white text
  - border `4px solid #d63031`
  - radius `4px`
  - bold sans-serif
  - pointer cursor
  - box shadow `0 4px 0 #d63031`
  - active state translates down `2px`
  - active shadow becomes `0 2px 0 #d63031`
- Visual style:
  - retro pixel/arcade CTA button

### Starter Item 2: `Lemonade`

- HTML:
  - `div` with class `.lemon-loader`
- CSS behavior:
  - size `40 x 40`
  - border `4px solid #ffe66d`
  - transparent top border
  - fully rounded
  - `spin 1s linear infinite`
- Visual style:
  - minimal circular loading spinner

## 9. Recreation Priorities For Another Agent

If another agent is rebuilding an asset sheet or playground, prioritize in this order:

1. Theme token system and all 15 presets
2. Outer shell proportions and corner radii
3. Editor panel + display panel split
4. Glass tab rail and glass accessory controls
5. Item row polygon shape and modal angled button shape
6. Footer controls and settings popover cards
7. Modal shell family
8. Embedded preview wrapper behavior

## 10. Practical Breakdown By Asset Type

### Buttons To Recreate

- Editor tab button
- Canvas add-tab button
- Canvas tab button
- Zoom cluster buttons
- Expand canvas button
- Collections add button
- Footer action square button
- Settings capsule button
- Backup rectangular button
- Angled modal button
- Collection selection row button

### Cards/Panels To Recreate

- Outer app shell
- Inner app shell
- Display area frame
- Canvas card
- Editor panel shell
- Editor section card
- Theme preset card
- Modal shell
- About panel

### Decorative Primitives To Recreate

- Window glass backdrop
- Dot matrix background overlay
- Polygon row shape
- Angled button shape
- Thin divider lines
- Bottom accent strips in modals
- Tiny color swatches

### Typography Styles To Recreate

- Large modal title
- Tiny uppercase section label
- Tiny monospaced status/metadata text
- Code editor monospaced text
- Rounded black micro-label buttons
- Splash attribution custom-font line

## 11. Source Map

Use these files if another agent needs to trace the source:

- Main app shell and almost all components:
  - `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag/GUI Bag Mac/ContentView.swift`
- Splash screen and launch-window behavior:
  - `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag/GUI Bag Mac/SplashScreenView.swift`
- About panel:
  - `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag/GUI Bag Mac/AboutWindow.swift`
- App fonts and icon bootstrap:
  - `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag/GUI Bag Mac/GUIBagMacApp.swift`
- Preview renderer:
  - `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag/GUI Bag Mac/CanvasRendererView.swift`
- Starter component CSS/HTML data:
  - `/Volumes/ALKI SD/MACBOOK PRO STORAGE/ALKI Corp Dev/GUI Bag/GUI Bag Mac/ItemStore.swift`

## 12. One-Line Summary

The app is a themed macOS console-style UI builder with a heavy rounded shell, glossy tab controls, a code-editor left column, a live preview right column, geometric list rows, and oversized cinematic modals, with theme presets driving almost every color decision.
