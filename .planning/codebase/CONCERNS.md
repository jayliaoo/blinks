# Codebase Concerns

**Analysis Date:** 2026-05-15

## Critical Issues

### Broken Sleep/Wake Handling for Eye Drop Timer

**Issue:** The eye drop timer and reminder window cleanup on system sleep are commented out, but the blink timer cleanup remains active. This creates asymmetric behavior where the blink timer stops on sleep but the eye drop timer continues running.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:180-185` (commented out invalidation and window cleanup in `systemWillSleep`)
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:195` (commented out restart in `systemDidWake`)

**Impact:**
- After the Mac sleeps, the eye drop timer does not reset, so `nextEyeDropTime` becomes stale
- If an open eye drop reminder window exists when sleep occurs, it remains open (ghost window) and may display stale information
- The eye drop timer may fire immediately upon wake if the sleep duration exceeded the interval
- Commit `55b20d8` ("Comment out eye drop timer and reminder window invalidation on system sleep") indicates this was intentionally disabled, likely due to a bug that was never properly resolved

**Fix approach:** Either properly re-enable sleep/wake handling with correct timer recalculation (recompute `nextEyeDropTime` on wake based on elapsed time), or remove the commented-out code and document the deliberate decision to ignore sleep events for the eye drop timer.

### App Sandbox Disabled

**Issue:** The app sandbox is explicitly disabled in the entitlements file, removing a fundamental macOS security boundary.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/Blinks.entitlements:6` (`com.apple.security.app-sandbox` set to `false`)

**Impact:** The app has unrestricted access to the user's filesystem, network, and system resources beyond what the user grants via permission dialogs. For a simple menu bar utility, this is excessive and would be a blocker for Mac App Store distribution.

**Fix approach:** Enable the app sandbox and add only the specific entitlements required (e.g., `com.apple.security.files.user-selected.read-only` if needed). The app currently uses `SMAppService.mainApp` for login items and standard AppKit APIs, both of which work within sandboxed apps.

## High Priority

### Implicitly Unwrapped Optionals (Force Unwraps)

**`statusItem` force unwrap risk:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:5`: `private var statusItem: NSStatusItem!`
- The status item is only initialized in `applicationDidFinishLaunching`. Any code path that accesses `statusItem` before launch completes will crash.

**`pauseMenuItem` force unwrap:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:87`: `menu.addItem(pauseMenuItem!)`
- `pauseMenuItem` is set on line 86 immediately before the force unwrap, so this is currently safe, but the pattern is fragile — any future refactoring that separates creation from use will introduce a crash risk.

**Fix approach:** Use proper optional binding (`guard let` / `if let`) or change declarations to non-optional with lazy initialization.

### Settings Window Management

**Issue:** The settings window is created fresh each time `toggleSettings()` is called when the stored reference is nil, but the reference becomes nil when the user closes the window via the red close button (without going through `toggleSettings`).

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:124-140` (`showSettings` creates new `NSWindow` + `NSHostingController` every call)
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:116-118` (`toggleSettings` only nils `settingsWindow` when it programmatically closes)

**Impact:**
- Each open/close cycle leaks an `NSWindow` and `NSHostingController` instance
- Over time this accumulates memory and view controller instances
- No `NSWindowDelegate` is set to detect when the user closes the window via the traffic light button

**Fix approach:** Set an `NSWindowDelegate` on the settings window to nil `settingsWindow` in `windowWillClose(_:)`. Alternatively, reuse a single window instance rather than creating new ones.

### Eye Drop Snooze Timer Runs on Main Run Loop Without Protection

**Issue:** The snooze timer is a one-shot timer (`repeats: false`) but uses the same `eyeDropTimer` variable as the recurring eye drop timer. If `restartEyeDropTimer()` is called while a snooze timer is active, it invalidates the snooze timer and starts a new recurring timer, potentially losing the snooze state.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:276-284` (`snoozeEyeDropTimer`)
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:254-256` (`restartEyeDropTimer`)

**Impact:** If the user changes settings during a snooze period, the snooze timer is cancelled and replaced with a full-interval timer, effectively losing the snooze.

**Fix approach:** Track snooze state separately (e.g., `isSnoozing: Bool` flag) or use a separate timer variable for snooze.

## Medium Priority

### No Test Coverage

**Issue:** Zero test files exist anywhere in the project. No XCTest targets, no test files, no mocking infrastructure.

**Files:** Entire codebase — no files matching `*Test*.swift` or `*test*.swift` found.

**Impact:**
- Any changes to timer logic, sleep/wake handling, or window management must be verified manually
- Regression risk is high, especially for the already-broken sleep/wake eye drop handling
- No safety net for refactoring

**Fix approach:** Add a test target with unit tests for timer management, settings persistence, and window lifecycle. Use `XCTest` with mock `NSStatusItem` and timer factories.

### `@AppStorage` on `NSObject` (Not Pure `ObservableObject`)

**Issue:** `AppDelegate` conforms to `ObservableObject` but uses `@AppStorage` for all settings. `@AppStorage` writes directly to `UserDefaults` and does NOT trigger `objectWillChange` by default. This means SwiftUI views observing `AppDelegate` may not always receive change notifications.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:4` (`ObservableObject` conformance)
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:13-20` (all `@AppStorage` properties)
- `/Users/mac/git/personal/blinks/Blinks/SettingsView.swift:4` (`@ObservedObject var appDelegate`)

**Impact:** In practice, `@AppStorage` on macOS does trigger view updates because SwiftUI subscribes to `UserDefaults` change notifications. However, this is an implementation detail — `@AppStorage` does not use `@Published` or `objectWillChange`. If other code observes `AppDelegate` via `@ObservedObject` expecting standard Combine publisher behavior, updates may not propagate as expected.

**Fix approach:** Either keep as-is (works in practice) but document the pattern, or migrate to `@Published` properties with explicit `UserDefaults` synchronization for clearer reactive semantics.

### `onHover` Cursor Handling Does Not Reset

**Issue:** The `.onHover` modifier on both buttons in `EyeDropReminderView` sets `NSCursor.pointingHand.set()` on hover but does NOT reset the cursor when hover ends.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/EyeDropReminderWindow.swift:119-121` (snooze button hover)
- `/Users/mac/git/personal/blinks/Blinks/EyeDropReminderWindow.swift:138-140` (done button hover)

**Impact:** After hovering over a button and then moving the cursor away, the pointing hand cursor persists until the user hovers over another UI element that sets its own cursor. This is a minor UX annoyance.

**Fix approach:** Reset cursor in the `false` branch: `.onHover { hovering in NSCursor.pointingHand.set() }` → `.onHover { hovering in hovering ? NSCursor.pointingHand.push() : NSCursor.pop() }` or use `.hoverEffect(.pointer)` in SwiftUI.

### Snooze Duration Slider Constraint Can Be Violated

**Issue:** The snooze duration slider's max value is computed dynamically (`let maxSnooze = min(appDelegate.eyeDropInterval, 1800)`), but the `@AppStorage` value for `eyeDropSnoozeDuration` can exceed this if the user first sets a large interval, then reduces the interval below the current snooze duration.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/SettingsView.swift:168-169`

**Impact:** The `@AppStorage` value for snooze duration can be higher than the current interval max, meaning the timer could snooze for longer than the original interval — defeating the purpose of snoozing.

**Fix approach:** Add a `didSet` or `onChange` handler that clamps `eyeDropSnoozeDuration` when `eyeDropInterval` changes.

### `CGDisplayIsAsleep` Only Checks Main Display

**Issue:** The display sleep check in `showBlinkAnimation()` only queries the main display, but the blink animation creates windows for ALL screens.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:219`

**Impact:** If a secondary display is asleep while the main display is awake, blink windows will be created for the sleeping display, which may cause unexpected behavior (waking the display, or windows appearing on a dark/unresponsive screen).

**Fix approach:** Check all displays in `NSScreen.screens` for sleep state before creating blink windows, or skip the check entirely if macOS handles this gracefully (which it often does with `level = .screenSaver`).

### `BlinkWindow` Only Stores Reference to Last Created Window

**Issue:** In `createBlinkWindow(for:)`, `self.window` is overwritten for each screen. On multi-display setups, only the last screen's window reference is retained.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/BlinkWindow.swift:59`

**Impact:** If a blink window needs to be dismissed programmatically (e.g., user clicks during animation), only the last-created window can be referenced. However, each window auto-closes after its animation, so this is currently low impact.

**Fix approach:** Store windows in an array: `private var windows: [NSWindow] = []` if programmatic window management is needed in the future.

### No Structured Logging

**Issue:** The only production logging is a single `print()` call in `setLaunchAtLogin`'s catch block. All other diagnostics are in preview stubs.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:234`

**Impact:** When timers fail, windows don't appear, or settings don't persist, there is no way to diagnose the issue without attaching a debugger. This is particularly problematic for a menu bar app that runs in the background.

**Fix approach:** Add a lightweight logging wrapper (e.g., `Logger` from `os.log`) with consistent log levels. At minimum, log timer creation/invalidation and window show/close events.

## Low Priority

### `SMAppService` Errors Silently Swallowed

**Issue:** Registration/unregistration failures for launch-at-login are logged but not surfaced to the user, and the `launchAtLogin` `@AppStorage` value may not reflect the actual system state.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:226-236`

**Impact:** If `SMAppService.mainApp.register()` fails, the toggle in settings still shows "on" even though the app won't launch at login.

**Fix approach:** If registration fails, reset the `@AppStorage` value to `false` and consider showing a user-facing alert.

### `DateFormatter` Created on Every Menu Open

**Issue:** A new `DateFormatter` instance is created each time `menuWillOpen` is called.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:98-100`

**Impact:** Negligible performance impact for this app, but `DateFormatter` is expensive to create. This is a good pattern to avoid in larger apps.

**Fix approach:** Cache the formatter as a static or lazy property.

### Hardcoded Window Dimensions in SettingsView

**Issue:** The settings view has a hardcoded `.frame(width: 400, height: 630)` which matches the window size set in `AppDelegate.showSettings()`.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/SettingsView.swift:213`
- `/Users/mac/git/personal/blinks/Blinks/AppDelegate.swift:132`

**Impact:** The two values must be kept in sync manually. If one changes and the other doesn't, the UI may clip or have excess space.

**Fix approach:** Define dimensions in a single constants file or use the `SettingsView` size as the source of truth.

### `ContentView.swift` Is Unused

**Issue:** `ContentView` is a minimal placeholder view that is never referenced by any other code in the app. The `BlinksApp` uses `EmptyView()` for its settings scene, and all UI is driven by `AppDelegate`.

**Files:**
- `/Users/mac/git/personal/blinks/Blinks/ContentView.swift`

**Impact:** Dead code that adds confusion.

**Fix approach:** Remove `ContentView.swift` if it serves no purpose.

## Security & Privacy Considerations

| Area | Status | Details |
|------|--------|---------|
| App Sandbox | **Disabled** | `Blinks.entitlements` sets `com.apple.security.app-sandbox` to `false` |
| User Data | Minimal | Only `UserDefaults` for settings — no personal data stored |
| Network Access | None | No network calls detected |
| Filesystem Access | None beyond app bundle | Uses `SMAppService` for login items |
| Permissions | Accessibility implied | Uses `NSApp.activate(ignoringOtherApps:)` — no explicit permission request |

## Edge Cases Not Handled

1. **Display configuration changes:** If a display is disconnected while a blink animation is in progress, the blink window for that display may not close cleanly (`/Users/mac/git/personal/blinks/Blinks/BlinkWindow.swift:37`)
2. **Rapid settings changes:** Changing `blinkInterval` and `blinkDuration` in quick succession creates multiple timer restarts (`/Users/mac/git/personal/blinks/Blinks/SettingsView.swift:31-32`)
3. **App quit during active blink/reminder:** If the user quits while a blink animation or eye drop reminder is showing, the windows are not explicitly cleaned up before termination
4. **Negative or zero values via UserDefaults editing:** If a user manually edits `UserDefaults` (via `defaults write`), they can set negative intervals or durations, which would cause timers to fire immediately or not at all

## Summary of Priorities

| Priority | Count | Key Items |
|----------|-------|-----------|
| Critical | 2 | Broken sleep/wake for eye drop, sandbox disabled |
| High | 4 | Force unwraps, settings window leak, snooze timer race |
| Medium | 7 | No tests, @AppStorage pattern, cursor reset, snooze clamp, display sleep, multi-screen window ref, no logging |
| Low | 5 | SMAppService errors, DateFormatter, hardcoded sizes, dead code, defaults injection |

---

*Concerns audit: 2026-05-15*
