# Testing Patterns

**Analysis Date:** 2026-05-15

## Test Framework

**Runner:** None configured. No test targets exist in the Xcode project (`Blinks.xcodeproj`).

**Assertion Library:** Not applicable.

**Config Files:** No `XCTest` target, no test scheme, no test bundles found in the project.

**Run Commands:** No automated test commands available. All testing is manual.

### Manual Build Commands
```bash
# Open in Xcode (for manual testing)
open Blinks.xcodeproj

# Build for debug (verify compilation)
xcodebuild -project Blinks.xcodeproj -scheme Blinks -configuration Debug build

# Build for release
./build.sh
```

## Test File Organization

**Current State:** No test files exist anywhere in the project.

**Search performed:** Searched for `*test*`, `*Test*`, `*spec*`, `*Spec*` — zero results.

**Xcode Project:** The `project.pbxproj` contains `ENABLE_TESTABILITY = YES` but no XCTest target is configured. No `BlinksTests/` directory exists.

### Recommended Test File Organization

If tests are added in the future, follow this structure:

```
Blinks/
├── BlinksTests/                  # New test target
│   ├── AppDelegateTests.swift    # Timer, pause, sleep/wake logic
│   ├── BlinkWindowTests.swift    # Window creation and animation
│   ├── SettingsViewTests.swift   # SwiftUI view rendering and bindings
│   └── EyeDropReminderTests.swift # Reminder window and snooze logic
```

## Test Coverage

**Current Coverage:** 0% — no tests exist.

**Lines of Code:** 794 total across 6 Swift files.

| File | Lines | Test Coverage |
|------|-------|---------------|
| `AppDelegate.swift` | 286 | None |
| `SettingsView.swift` | 244 | None |
| `EyeDropReminderWindow.swift` | 156 | None |
| `BlinkWindow.swift` | 81 | None |
| `BlinksApp.swift` | 12 | None |
| `ContentView.swift` | 15 | None |

## Untested Areas Requiring Coverage

### Critical: AppDelegate Timer Logic (`Blinks/AppDelegate.swift`)

**What's not tested:**
- Timer creation and invalidation cycle (`startBlinkTimer`, `startEyeDropTimer`)
- Pause/resume toggle behavior (`togglePause`)
- Sleep/wake notification handling (`systemWillSleep`, `systemDidWake`)
- Menu dynamic updates (`menuWillOpen`, `updateMenu`)
- Launch at login registration (`setLaunchAtLogin`)
- `@AppStorage` persistence and defaults

**Risk:** Timer bugs (double-firing, not restarting after wake) are the most common failure modes in this app. Without tests, these regress silently.

**Priority:** HIGH

### High: Eye Drop Reminder Flow (`Blinks/AppDelegate.swift:241-285`, `EyeDropReminderWindow.swift`)

**What's not tested:**
- Snooze timer creation with correct interval
- Window close and cleanup on done/snooze
- Timer restart after user action
- Disabled state handling

**Risk:** Memory leaks from unreleased window references; timer drift from incorrect restart.

**Priority:** HIGH

### Medium: Settings View Bindings (`Blinks/SettingsView.swift`)

**What's not tested:**
- Slider value changes propagate to `@AppStorage`
- Toggle enable/disable logic
- `formatInterval()` helper function (pure function — easy to test)
- `onChange` handlers restart timers correctly

**Priority:** MEDIUM

### Medium: Blink Window Multi-Display (`Blinks/BlinkWindow.swift`)

**What's not tested:**
- Window creation for multiple screens
- Animation timing and cleanup
- Display-asleep skip logic

**Priority:** MEDIUM

### Low: App Entry Point (`Blinks/BlinksApp.swift`)

**What's not tested:**
- App lifecycle bootstrapping
- `@NSApplicationDelegateAdaptor` wiring

**Priority:** LOW (primarily framework wiring)

## Manual Testing Procedures

The following manual test scenarios are implied by the code structure:

### Startup Test
1. Launch app from Xcode or built `.app`
2. Verify eye icon appears in menu bar
3. Verify menu contains: Settings, Pause, Quit items
4. Wait for first blink interval (default 60s) — verify full-screen overlay appears and fades

### Settings Test
1. Open Settings from menu bar
2. Adjust blink interval slider — verify value updates in real time
3. Adjust blink duration slider
4. Adjust opacity slider
5. Toggle eye drop reminder — verify snooze controls appear/disappear
6. Toggle launch at login
7. Close settings — verify changes persist after relaunch

### Pause/Resume Test
1. Click Pause in menu — verify menu item changes to "Resume"
2. Wait for expected blink interval — verify no blink occurs
3. Click Resume — verify blink resumes at next interval

### Sleep/Wake Test
1. Put Mac to sleep (`Apple menu > Sleep`)
2. Wake Mac
3. Verify blink timer restarts automatically

### Eye Drop Reminder Test
1. Wait for eye drop interval (default 30 min) or trigger via `testEyeDropReminder()`
2. Verify reminder window appears with "Done" and "Snooze" buttons
3. Click Done — verify window closes, timer restarts
4. Click Snooze — verify window closes, snooze timer starts

## Testing Challenges (macOS Menu Bar App)

### 1. Menu Bar Integration Testing
**Problem:** `NSStatusItem` requires an active `NSApplication` run loop. Standard XCTest cannot easily test menu bar items.

**Recommended Approach:** Use `XCTestCase` with `NSApplication.shared` in the test target, or use UI tests (`XCUIApplication`) to interact with the status bar.

### 2. Timer-Dependent Testing
**Problem:** Default intervals are 60s (blink) and 30min (eye drop). Tests cannot wait this long.

**Recommended Approach:**
- Inject a testable `Clock` protocol or allow interval override via a test-only setter on `AppDelegate`
- Example pattern:
  ```swift
  // In production: blinkInterval = 60.0
  // In test: appDelegate.blinkInterval = 0.1  // 100ms
  ```

### 3. Window Overlay Testing
**Problem:** `BlinkWindow` creates `NSWindow` instances with `level = .screenSaver`. These interfere with test execution and cannot be easily inspected.

**Recommended Approach:**
- Extract window creation logic into a testable factory/protocol
- Test the configuration values (level, style mask, frame) without actually showing the window

### 4. Sleep/Wake Notification Testing
**Problem:** `NSWorkspace.willSleepNotification` and `didWakeNotification` cannot be triggered programmatically.

**Recommended Approach:**
- Extract the notification observer registration into an injectable dependency
- Post `NSNotification` directly in tests:
  ```swift
  NotificationCenter.default.post(name: NSWorkspace.didWakeNotification, object: nil)
  ```

### 5. UserDefaults (@AppStorage) Testing
**Problem:** `@AppStorage` reads from `UserDefaults.standard`. Tests share the same defaults domain and can leak state between tests.

**Recommended Approach:**
- Reset `UserDefaults` in `setUp()` and `tearDown()`:
  ```swift
  override func tearDown() {
      let keys = ["blinkInterval", "blinkDuration", "blinkOpacity", "eyeDropInterval",
                  "eyeDropSnoozeDuration", "eyeDropEnabled", "launchAtLogin", "isPaused"]
      keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
      super.tearDown()
  }
  ```

### 6. SwiftUI Preview Testing
**Problem:** `#Preview` blocks exist in `EyeDropReminderWindow.swift` and `ContentView.swift` but have no assertions.

**Recommended Approach:** Use `ViewInspector` or `SwiftUISnapshotTesting` for programmatic view verification:
```swift
func testSettingsViewRenders() {
    let appDelegate = AppDelegate()
    let view = SettingsView(appDelegate: appDelegate)
    XCTAssertNoThrow(try view.inspect())
}
```

## Recommended Test Strategies

### Phase 1: Unit Tests (Recommended First)
- **Target:** `BlinksTests` (XCTest)
- **Focus:** Pure logic and data flow
- **Testable units:**
  - `formatInterval()` in `SettingsView` — pure function, no mocking needed
  - Timer state transitions in `AppDelegate` (pause, resume, restart)
  - `@AppStorage` default values
  - Eye drop snooze interval calculation

### Phase 2: Integration Tests
- **Target:** `BlinksUITests` (XCUITest)
- **Focus:** End-to-end user flows
- **Testable flows:**
  - Settings changes persist across app relaunch
  - Menu bar interaction (open menu, click pause, click settings)
  - Window appearance and dismissal

### Phase 3: Snapshot Tests (Optional)
- **Framework:** `iOSSnapshotTestCase` or `SwiftUISnapshotTesting`
- **Focus:** Visual regression for settings UI and reminder window
- **Candidates:** `SettingsView`, `EyeDropReminderView`, `BlinkView`

## Fixtures and Factories

**Current:** None exist.

**Recommended:** Create test helpers for common test data:
```swift
// BlinksTests/TestHelpers.swift
extension AppDelegate {
    static func testDefaults() -> AppDelegate {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "blinkInterval")
        defaults.removeObject(forKey: "eyeDropEnabled")
        // ... reset all keys
        return AppDelegate()
    }
}
```

## Coverage Requirements

**Current:** None enforced.

**Recommended Target:** 60% minimum (achievable with unit tests on AppDelegate logic and SettingsView helpers).

**View Coverage:** Not available (no test framework configured). Would require:
```bash
xcodebuild test -project Blinks.xcodeproj -scheme BlinksTests -enableCodeCoverage YES
```

## Test Types Summary

| Type | Framework | Status | Priority |
|------|-----------|--------|----------|
| Unit Tests | XCTest | Not present | HIGH |
| Integration Tests | XCUITest | Not present | MEDIUM |
| E2E Tests | XCUITest | Not present | LOW |
| Snapshot Tests | SwiftUISnapshotTesting | Not present | LOW |

---

*Testing analysis: 2026-05-15*
