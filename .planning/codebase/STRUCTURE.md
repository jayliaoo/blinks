# Codebase Structure

**Analysis Date:** 2026-05-15

## Directory Layout

```
/Users/mac/git/personal/blinks/
├── Blinks/                           # Main app target (single Xcode target)
│   ├── BlinksApp.swift               # @main entry point
│   ├── AppDelegate.swift             # Central coordinator (state, timers, menu, sleep/wake)
│   ├── BlinkWindow.swift             # Full-screen blink overlay (BlinkWindow + BlinkView)
│   ├── EyeDropReminderWindow.swift   # Floating reminder (EyeDropReminderWindow + EyeDropReminderView)
│   ├── SettingsView.swift            # SwiftUI settings panel + formatInterval helper
│   └── ContentView.swift             # Unused placeholder view
├── Blinks.xcodeproj/                 # Xcode project
│   ├── project.pbxproj               # Project definition (single target: Blinks)
│   ├── project.xcworkspace/          # Workspace
│   └── xcuserdata/                   # User-specific Xcode data
├── build/                            # Build output (gitignored)
│   ├── Blinks.xcarchive/             # Archived build
│   └── DerivedData/                  # Xcode derived data
├── Blinks/Blinks.entitlements        # App sandbox permissions
├── Blinks/Info.plist                 # App bundle configuration
├── build.sh                          # CLI build script (xcodebuild archive + export)
├── exportOptions.plist               # xcodebuild export configuration
├── CLAUDE.md                         # AI assistant guide
├── AGENTS.md                         # Agent guidelines
├── README.md                         # User-facing documentation
├── LICENSE                           # MIT license
└── .gitignore                        # Git ignore rules
```

## Directory Purposes

**`Blinks/` (source root):**
- Purpose: All app source code lives in a single flat directory — no subfolders
- Contains: 6 Swift files (5 production + 1 unused), 1 entitlements plist, 1 Info.plist
- Key files: `AppDelegate.swift` (central logic), `BlinksApp.swift` (entry point)

**`Blinks.xcodeproj/`:**
- Purpose: Xcode project configuration
- Contains: Single target "Blinks", macOS deployment target 13.0
- Key files: `project.pbxproj`

**`build/`:**
- Purpose: Build artifacts — compiled .app, archives, derived data
- Generated: Yes (by `build.sh` or Xcode)
- Committed: No (in `.gitignore`)

## Key File Locations

**Entry Points:**
- `Blinks/BlinksApp.swift:3`: `@main struct BlinksApp` — app lifecycle root
- `Blinks/AppDelegate.swift:30`: `applicationDidFinishLaunching` — runtime initialization

**Configuration:**
- `Blinks/Info.plist`: Bundle metadata, `LSUIElement=true` (menu-bar-only mode)
- `Blinks/Blinks.entitlements`: Sandbox disabled, Apple Events enabled
- `exportOptions.plist`: `mac-application` export method, automatic signing
- `build.sh`: Archive-based build with optional DMG packaging

**Core Logic:**
- `Blinks/AppDelegate.swift`: 287 lines — timers, menu bar, state, sleep/wake, window creation
- `Blinks/BlinkWindow.swift`: 82 lines — multi-display overlay with animation
- `Blinks/EyeDropReminderWindow.swift`: 157 lines — reminder window + SwiftUI view

**Testing:**
- No test target exists. `#Preview` blocks present in:
  - `Blinks/SettingsView.swift:241`
  - `Blinks/EyeDropReminderWindow.swift:151`
  - `Blinks/ContentView.swift:13`

## File Dependency Graph

```
BlinksApp.swift
    │
    └── @NSApplicationDelegateAdaptor ──► AppDelegate.swift
                                              │
                                              ├── creates ──► SettingsView.swift
                                              │                   │
                                              │                   └── reads/writes @AppStorage on AppDelegate
                                              │
                                              ├── creates ──► BlinkWindow.swift
                                              │                   │
                                              │                   └── BlinkView (SwiftUI, same file)
                                              │
                                              └── creates ──► EyeDropReminderWindow.swift
                                                                  │
                                                                  └── EyeDropReminderView (SwiftUI, same file)

ContentView.swift  ──► (not referenced by any production code)
```

### Dependency Rules Observed

1. **All dependencies flow from `AppDelegate`** — it is the sole creator of all windows and views
2. **SwiftUI views in same file as window wrappers** — `BlinkView` lives with `BlinkWindow`, `EyeDropReminderView` lives with `EyeDropReminderWindow`
3. **No cross-file imports between app source files** — only framework imports (`SwiftUI`, `AppKit`, `ServiceManagement`)
4. **`SettingsView` depends on `AppDelegate`** as `@ObservedObject` — no protocol abstraction

## Naming Conventions

**Files:**
- `PascalCase.swift` for all types (matching the primary type in the file)
- Example: `BlinkWindow.swift` contains `BlinkWindow` class and `BlinkView` struct

**Types:**
- Classes: `PascalCase` — `AppDelegate`, `BlinkWindow`, `EyeDropReminderWindow`
- Structs (SwiftUI views): `PascalCase` with "View" suffix — `SettingsView`, `BlinkView`, `EyeDropReminderView`, `ContentView`

**Functions/Methods:**
- `camelCase` — `startBlinkTimer()`, `showBlinkAnimation()`, `togglePause()`, `systemWillSleep()`
- `@objc` methods use same camelCase — `showMenu()`, `toggleSettings()`, `blinkNow()`

**Variables/Properties:**
- `camelCase` — `blinkTimer`, `statusItem`, `blinkInterval`, `nextEyeDropTime`
- Private members explicitly marked `private` — `blinkTimer`, `eyeDropTimer`, `settingsWindow`
- UserDefaults keys use `camelCase` strings — `"blinkInterval"`, `"eyeDropEnabled"`

**Constants:**
- No explicit `static let` constants observed; values are inline or in `@AppStorage` defaults

## Module/Package Boundaries

- **Single target:** "Blinks" — no SPM packages, no frameworks, no sub-targets
- **External frameworks used:**
  - `SwiftUI` — UI framework (all view files)
  - `AppKit` — window management (`NSWindow`, `NSStatusBar`, `NSMenu`, `NSWorkspace`)
  - `ServiceManagement` — launch-at-login (`SMAppService`)
- **No third-party dependencies** — zero SPM/Carthage/CocoaPods packages

## Type Relationships

### AppDelegate (`Blinks/AppDelegate.swift:4`)

```
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSMenuDelegate
```

**Owns:**
- `statusItem: NSStatusItem!` — menu bar icon
- `settingsWindow: NSWindow?` — settings panel
- `blinkTimer: Timer?` — periodic blink trigger
- `eyeDropTimer: Timer?` — periodic eye-drop trigger
- `eyeDropReminderWindow: EyeDropReminderWindow?` — active reminder
- `pauseMenuItem: NSMenuItem?` — dynamic menu item reference
- `nextEyeDropTime: Date?` — next scheduled reminder time

**@AppStorage properties (8 total):**
- `blinkInterval`, `blinkDuration`, `blinkOpacity`
- `eyeDropInterval`, `eyeDropSnoozeDuration`, `eyeDropEnabled`
- `launchAtLogin`, `isPaused`

### BlinkWindow (`Blinks/BlinkWindow.swift:4`)

```
class BlinkWindow { ... }
struct BlinkView: View { ... }
```

- Plain class (no protocols)
- Takes `opacity` and `duration` via initializer
- `show()` method creates windows; no public properties

### EyeDropReminderWindow (`Blinks/EyeDropReminderWindow.swift:4`)

```
class EyeDropReminderWindow { ... }
struct EyeDropReminderView: View { ... }
```

- Plain class with closure callbacks
- `init(onDone: @escaping () -> Void, onSnooze: @escaping () -> Void)`
- `show()` and `close()` methods

## Where to Add New Code

**New Feature (app behavior):**
- Primary code: `Blinks/AppDelegate.swift` — add methods, timers, state properties
- If creating new UI: new file in `Blinks/` alongside existing window files

**New Settings:**
- Add `@AppStorage("keyName")` property in `AppDelegate.swift`
- Add corresponding UI control in `SettingsView.swift`
- Use `onChange` or `didSet` to react, call appropriate `restart...Timer()` method

**New Window/Overlay:**
- Create `NewFeatureWindow.swift` in `Blinks/`
- Follow pattern: plain class with `show()` method + SwiftUI view struct in same file
- Window instance stored as optional property in `AppDelegate`

**Utilities/Helpers:**
- Shared helpers: inline in `AppDelegate` or new file in `Blinks/`
- Currently no dedicated utilities directory or file exists

**New Timer/Scheduler:**
- Add timer property in `AppDelegate`
- Add `start...Timer()` and `restart...Timer()` methods
- Invalidate in `togglePause()`, `systemWillSleep()`, and `deinit`

## Special Directories

**`build/`:**
- Purpose: Build output — .app bundle, xcarchive, DerivedData
- Generated: Yes (by `build.sh` or Xcode)
- Safe to delete: Yes (will be regenerated)

**`.planning/`:**
- Purpose: GSD planning documents
- Generated: Yes (by `/gsd:map-codebase`)

**`Blinks.xcodeproj/project.xcworkspace/`:**
- Purpose: Xcode workspace metadata
- Committed: Yes

## Observed Structural Notes

1. **Flat structure:** All 6 Swift files in a single directory — no sub-grouping by feature or layer
2. **Co-located view + window:** Each window class ships with its SwiftUI view in the same file (reduces file count, tight coupling)
3. **No Resources folder:** No images, sounds, or asset catalogs — all icons use `NSImage(systemSymbolName:)`
4. **No tests directory:** Zero unit or integration tests
5. **ContentView.swift is dead code:** Not imported or referenced anywhere in production

---

*Structure analysis: 2026-05-15*
