# Coding Conventions

**Analysis Date:** 2026-05-15

## Naming Conventions

**Files:**
- PascalCase for all Swift files matching their type names (e.g., `AppDelegate.swift`, `BlinkWindow.swift`, `EyeDropReminderWindow.swift`, `SettingsView.swift`)
- CamelCase for app name prefix: `BlinksApp.swift`

**Types:**
- Classes: PascalCase (`AppDelegate`, `BlinkWindow`, `EyeDropReminderWindow`)
- Structs (SwiftUI views): PascalCase (`BlinksApp`, `SettingsView`, `BlinkView`, `EyeDropReminderView`, `ContentView`)

**Functions and Methods:**
- camelCase for all methods (`startBlinkTimer()`, `showBlinkAnimation()`, `togglePause()`, `systemWillSleep()`)
- `@objc` methods exposed to Objective-C runtime follow same camelCase (`showMenu()`, `blinkNow()`, `quit()`)

**Variables and Properties:**
- camelCase for all variables (`blinkTimer`, `eyeDropInterval`, `statusItem`)
- Private properties use explicit `private` modifier (`private var blinkTimer: Timer?`)
- Bool properties use descriptive affirmative names (`isPaused`, `eyeDropEnabled`)

**Constants:**
- Named constants at property level with descriptive names (`blinkInterval`, `blinkDuration`)
- Magic numbers in UI code use inline literals (colors, sizes, spacing values)

## Access Control

**Pattern:** Explicit `private` for internal implementation details; default (internal) for framework-required methods.

| Modifier | Usage | Examples |
|----------|-------|----------|
| `private var` | Internal state, timers, windows | `private var blinkTimer: Timer?` |
| `private func` | Internal helpers | `private func updateMenu()`, `private func showSettings()` |
| `@objc private func` | Notification handlers | `@objc private func systemWillSleep()` |
| `func` (internal) | Framework delegate methods, public APIs | `func applicationDidFinishLaunching(_:)`, `func menuWillOpen(_:)` |
| No modifier (internal) | Restart methods for SwiftUI triggers | `func restartBlinkTimer()` |

**Observation:** Methods that need to be called from SwiftUI views (`restartBlinkTimer()`, `restartEyeDropTimer()`) are left at internal visibility rather than private. Properties exposed via `@AppStorage` are also internal by design.

## State Management

**Centralized State in AppDelegate (`Blinks/AppDelegate.swift`):**
- `AppDelegate` conforms to `ObservableObject` to act as the single source of truth
- All settings use `@AppStorage` for automatic UserDefaults persistence:
  ```swift
  @AppStorage("blinkInterval") var blinkInterval: Double = 60.0
  @AppStorage("blinkDuration") var blinkDuration: Double = 1.0
  @AppStorage("blinkOpacity") var blinkOpacity: Double = 0.5
  @AppStorage("eyeDropInterval") var eyeDropInterval: Double = 1800.0
  @AppStorage("eyeDropSnoozeDuration") var eyeDropSnoozeDuration: Double = 300.0
  @AppStorage("eyeDropEnabled") var eyeDropEnabled: Bool = true
  @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
  @AppStorage("isPaused") var isPaused: Bool = false
  ```

**Key naming convention:** UserDefaults keys match property names exactly (e.g., `"blinkInterval"` for `blinkInterval`).

**View-level State:**
- `@ObservedObject` used to inject `AppDelegate` into `SettingsView`:
  ```swift
  struct SettingsView: View {
      @ObservedObject var appDelegate: AppDelegate
  ```
- `@NSApplicationDelegateAdaptor` in `BlinksApp.swift` connects AppDelegate to SwiftUI lifecycle:
  ```swift
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  ```

**Side-effect Pattern:** When a setting change requires action beyond persistence, a custom `Binding` is used in the view:
  ```swift
  Toggle(isOn: Binding(
      get: { appDelegate.launchAtLogin },
      set: { newValue in
          appDelegate.launchAtLogin = newValue
          appDelegate.setLaunchAtLogin(newValue)
      }
  )) { ... }
  ```
  Same pattern for the eye drop enabled toggle.

**Non-@AppStorage State:** `nextEyeDropTime` is a private `Date?` property (not persisted) used for displaying the next reminder time in the menu bar.

## SwiftUI vs AppKit Usage

**Division of Responsibility:**
- **SwiftUI** is used for view composition and layout (`SettingsView`, `EyeDropReminderView`, `BlinkView`)
- **AppKit** is used for window management, menu bar items, and system integration (`NSWindow`, `NSStatusItem`, `NSMenu`, `NSHostingController`)

**Integration Pattern — NSHostingController:**
SwiftUI views are embedded into AppKit windows via `NSHostingController`:
```swift
// In AppDelegate.swift:127-129
let hostingController = NSHostingController(rootView: settingsView)
let window = NSWindow(contentViewController: hostingController)
```

```swift
// In BlinkWindow.swift:25-27
let hostingController = NSHostingController(rootView: blinkView)
let window = NSWindow(contentViewController: hostingController)
```

**Window Configuration Pattern:**
Windows are configured with explicit style masks and properties:
```swift
// BlinkWindow — full-screen overlay
window.styleMask = [.borderless, .fullSizeContentView]
window.level = .screenSaver
window.backgroundColor = .clear
window.isOpaque = false
window.hasShadow = false
window.ignoresMouseEvents = true
window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

// EyeDropReminderWindow — floating reminder
window.styleMask = [.titled, .fullSizeContentView]
window.level = .floating
window.hasShadow = true
```

## Timer Patterns

**Three-phase pattern used consistently:**
1. Invalidate existing timer
2. Set to nil
3. Create new timer with tolerance

Example from `startBlinkTimer()` (`AppDelegate.swift:201-210`):
```swift
private func startBlinkTimer() {
    guard !isPaused else { return }
    blinkTimer?.invalidate()
    blinkTimer = nil
    let timer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { [weak self] _ in
        self?.showBlinkAnimation()
    }
    timer.tolerance = blinkInterval * 0.1
    blinkTimer = timer
}
```

**Tolerance Convention:** Always set `timer.tolerance` for power efficiency:
- Blink timer: `timer.tolerance = blinkInterval * 0.1` (10% of interval)
- Eye drop timer: `timer.tolerance = min(eyeDropInterval * 0.1, 60.0)` (capped at 1 minute)
- Snooze timer: `timer.tolerance = min(eyeDropSnoozeDuration * 0.1, 30.0)` (capped at 30 seconds)

## Closure and Callback Patterns

**Weak Self:** All closure-based callbacks consistently use `[weak self]` capture lists:
- Timer closures: 5 instances in `AppDelegate.swift`
- Callback chains: 2 instances in `AppDelegate.swift` (eye drop done/snooze), 2 in `EyeDropReminderWindow.swift`
- DispatchQueue: 1 instance in `AppDelegate.swift:190`

**Pattern:**
```swift
Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
    self?.showBlinkAnimation()
}

DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    // ...
}
```

**Escaping Closures:** Callback parameters use `@escaping`:
```swift
init(onDone: @escaping () -> Void, onSnooze: @escaping () -> Void)
```

**Optional Chaining on Callbacks:** Callbacks are stored as optionals and invoked with `?()`:
```swift
self?.onDone?()
self?.onSnooze?()
```

## Error Handling

**Strategy:** Guard-early-return with optional unwrapping; catch-and-log for async operations.

**Guard Pattern:** Used for early exits throughout:
```swift
guard !isPaused else { return }
guard !isPaused && eyeDropEnabled else { return }
guard CGDisplayIsAsleep(CGMainDisplayID()) == 0 else { return }
guard let self = self else { return }
```

**If-let Pattern:** Used for optional unwrapping:
```swift
if let button = statusItem.button { ... }
if let window = settingsWindow, window.isVisible { ... }
if eyeDropEnabled, let nextTime = nextEyeDropTime { ... }
```

**Do-catch Pattern:** Only used once in `setLaunchAtLogin()` (`AppDelegate.swift:226-236`):
```swift
do {
    if enabled {
        try SMAppService.mainApp.register()
    } else {
        try SMAppService.mainApp.unregister()
    }
} catch {
    print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
}
```

**Logging:** Only `print()` is used. No dedicated logging framework. Single production print statement for launch-at-login errors.

## Code Organization

**File-level Organization:**
- No explicit file header comments
- Imports at top of each file (SwiftUI, AppKit, ServiceManagement as needed)
- Single primary type per file (class or struct)

**Class-level Organization (AppDelegate):**
1. Properties (private vars, @AppStorage, private vars)
2. `deinit`
3. `applicationDidFinishLaunching` (lifecycle)
4. Menu methods (`updateMenu`, `showMenu`, `menuWillOpen`)
5. Action methods (`toggleSettings`, `blinkNow`, `testEyeDropReminder`, `togglePause`, `quit`)
6. MARK: sections (`Sleep/Wake Handlers`, `Eye Drop Reminder`)

**MARK: Usage:** Two MARK sections observed in `AppDelegate.swift`:
- `// MARK: - Sleep/Wake Handlers` (line 174)
- `// MARK: - Eye Drop Reminder` (line 239)

**Note:** No other MARK sections in the codebase. Settings, timers, and menu methods are not sectioned.

## Function Design

**Size:** All functions are short (under 30 lines each). The longest method is `showSettings()` at ~15 lines.

**Parameters:** Methods either take no parameters or a single parameter. The only multi-parameter initializer is `EyeDropReminderWindow.init(onDone:onSnooze:)`.

**Return Values:** All methods return `Void`. No methods have return types.

**@objc Methods:** Methods invoked via `#selector` are marked `@objc`:
```swift
@objc func showMenu()
@objc func toggleSettings()
@objc func blinkNow()
@objc func testEyeDropReminder()
@objc func togglePause()
@objc func quit()
@objc private func systemWillSleep()
@objc private func systemDidWake()
```

## Import Organization

**Order per file:**
1. `import SwiftUI` (always first, in every file)
2. `import AppKit` (second, where AppKit types are used directly)
3. `import ServiceManagement` (third, only in AppDelegate)

**Path Aliases:** No import path aliases defined. This is a single-target Xcode project.

## SwiftUI Conventions

**View Body:** All views use `some View` return type:
```swift
var body: some View { ... }
```

**Preview Provider:** `#Preview` macro used (modern SwiftUI):
```swift
#Preview {
    EyeDropReminderView(onDone: { print("Done") }, onSnooze: { print("Snooze") })
}
```

**Modifier Chaining:** Heavy use of method chaining for view styling. No custom view modifiers defined.

**Safe Area:** `edgesIgnoringSafeArea(.all)` used on overlay views (blink and eye drop backgrounds).

## Comments

**Style:** Line comments with `//` only. No block comments.

**When Comments Are Used:**
- Inline explanations for magic values: `// 1 minute in seconds`
- Purpose explanations for code blocks: `// Create menu bar item`
- Section markers: `// MARK: - Sleep/Wake Handlers`
- Workaround notes: commented-out code with explanations for sleep handling (lines 180-185, 195)

**Commented-out Code:** Two sections of commented-out code exist in `systemWillSleep()`:
```swift
// eyeDropTimer?.invalidate()
// eyeDropTimer = nil
// eyeDropReminderWindow?.close()
// eyeDropReminderWindow = nil
```
These are intentional (documented in commit history as refactoring).

## Code Style Observations

**Spacing:** Consistent blank line between method declarations. No blank lines within short methods.

**Braces:** Allman-style braces (opening brace on same line as declaration).

**Indentation:** 4-space indentation throughout.

**Line Length:** No line exceeds ~90 characters.

---

*Convention analysis: 2026-05-15*
