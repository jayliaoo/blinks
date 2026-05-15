<!-- refreshed: 2026-05-15 -->
# Architecture

**Analysis Date:** 2026-05-15

## System Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│                        BlinksApp.swift                          │
│                    @main App Entry Point                        │
│                   (SwiftUI App lifecycle)                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │ @NSApplicationDelegateAdaptor
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                       AppDelegate.swift                         │
│         NSApplicationDelegate + ObservableObject (central)       │
├──────────────┬──────────────────┬───────────────────────────────┤
│  Menu Bar    │   Timer Engine   │        State Storage          │
│  NSStatusItem│  blinkTimer      │  @AppStorage (UserDefaults)   │
│  NSMenu      │  eyeDropTimer    │  blinkInterval, blinkDuration,│
│              │  tolerance logic │  blinkOpacity, eyeDropInterval│
└──────┬───────┴────────┬─────────┴──────────┬────────────────────┘
       │                │                     │
       ▼                ▼                     ▼
┌──────────────┐ ┌──────────────────┐ ┌──────────────────────────┐
│ Settings     │ │  BlinkWindow     │ │ EyeDropReminderWindow    │
│ NSWindow +   │ │  NSPanel         │ │ NSWindow (.floating)     │
│ NSHostingCtrl│ │  .screenSaver    │ │ + EyeDropReminderView    │
│ + SettingsVw │ │  + BlinkView     │ │  Snooze / Done actions   │
└──────────────┘ └──────────────────┘ └──────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| `BlinksApp` | App entry point; wires `AppDelegate` via `@NSApplicationDelegateAdaptor` | `Blinks/BlinksApp.swift:4` |
| `AppDelegate` | Central coordinator: menu bar, timers, settings sync, sleep/wake, pause/resume | `Blinks/AppDelegate.swift:4` |
| `BlinkWindow` | Creates full-screen `NSPanel` on all displays, animates opacity fade | `Blinks/BlinkWindow.swift:4` |
| `BlinkView` | SwiftUI view rendering black overlay with "Blink Your Eyes!" text | `Blinks/BlinkWindow.swift:63` |
| `EyeDropReminderWindow` | Creates floating reminder window with Done/Snooze buttons | `Blinks/EyeDropReminderWindow.swift:4` |
| `EyeDropReminderView` | SwiftUI view with gradient background, drop icon, action buttons | `Blinks/EyeDropReminderWindow.swift:53` |
| `SettingsView` | SwiftUI settings panel with sliders/toggles for all configurable parameters | `Blinks/SettingsView.swift:3` |
| `ContentView` | Unused placeholder view (not referenced in production) | `Blinks/ContentView.swift:3` |

## Pattern Overview

**Overall:** Menu-bar-only app with a single central `AppDelegate` acting as controller, view coordinator, and state manager. No MVVM separation — `AppDelegate` owns both state (`@AppStorage`) and presentation logic.

**Key Characteristics:**
- Single-point state management via `@AppStorage` in `AppDelegate`
- `AppDelegate` conforms to both `NSApplicationDelegate` and `ObservableObject` — bridging AppKit lifecycle with SwiftUI reactivity
- Window creation is imperative (AppKit-style) rather than declarative SwiftUI scenes
- Closure-based callbacks (`onDone`, `onSnooze`) for inter-component communication
- All UI triggered from the menu bar status item

## Layers

**App Lifecycle Layer:**
- Purpose: Bootstrap the app, install menu bar, register observers
- Location: `Blinks/BlinksApp.swift`, `Blinks/AppDelegate.swift:30-63`
- Contains: `@main` struct, `NSApplicationDelegate` methods
- Depends on: SwiftUI, ServiceManagement framework
- Used by: System (app launch)

**State & Timer Layer:**
- Purpose: Maintain settings, schedule blink/eye-drop events, handle pause/resume and sleep/wake
- Location: `Blinks/AppDelegate.swift:13-20` (state), `201-285` (timers)
- Contains: `@AppStorage` properties, `Timer` instances, `Date` tracking
- Depends on: Foundation (`Timer`, `Date`), `CGDisplayIsAsleep`
- Used by: All presentation components

**Presentation Layer:**
- Purpose: Render UI — settings panel, blink overlay, eye-drop reminder
- Location: `Blinks/SettingsView.swift`, `Blinks/BlinkWindow.swift`, `Blinks/EyeDropReminderWindow.swift`
- Contains: SwiftUI views, `NSWindow`/`NSPanel` wrappers
- Depends on: SwiftUI, AppKit
- Used by: `AppDelegate` (creates and shows windows)

## Data Flow

### Primary Blink Cycle Path

1. **App launches** — `BlinksApp` creates `AppDelegate` via adaptor (`Blinks/BlinksApp.swift:5`)
2. **`applicationDidFinishLaunching`** fires — creates status item, builds menu, starts timers (`Blinks/AppDelegate.swift:30`)
3. **`startBlinkTimer()`** schedules repeating `Timer` at `blinkInterval` (`Blinks/AppDelegate.swift:201-211`)
4. **Timer fires** — calls `showBlinkAnimation()` (`Blinks/AppDelegate.swift:217`)
5. **Display-asleep guard** — skips if `CGDisplayIsAsleep` returns true (`Blinks/AppDelegate.swift:219`)
6. **`BlinkWindow.show()`** creates one `NSPanel` per screen at `.screenSaver` level (`Blinks/BlinkWindow.swift:14-21`)
7. **Opacity animation** — fades in over 0.15s, holds for `blinkDuration`, fades out over 0.15s, self-closes (`Blinks/BlinkWindow.swift:43-57`)

### Eye Drop Reminder Path

1. **`startEyeDropTimer()`** schedules repeating `Timer` at `eyeDropInterval`, records `nextEyeDropTime` (`Blinks/AppDelegate.swift:241-252`)
2. **Timer fires** — calls `showEyeDropReminder()` (`Blinks/AppDelegate.swift:258`)
3. **`EyeDropReminderWindow`** created with `onDone`/`onSnooze` closures (`Blinks/AppDelegate.swift:261-273`)
4. **User taps Done** — window closes, `restartEyeDropTimer()` fires normal interval
5. **User taps Snooze** — window closes, `snoozeEyeDropReminder()` fires one-shot timer at `eyeDropSnoozeDuration` (`Blinks/AppDelegate.swift:276-285`)

### Settings Change Path

1. **User opens Settings** via menu item → `toggleSettings()` (`Blinks/AppDelegate.swift:115`)
2. **`SettingsView`** binds directly to `@AppStorage` properties on `AppDelegate` via `$appDelegate.property`
3. **Slider changes** trigger `onChange` → call `appDelegate.restartBlinkTimer()` / `restartEyeDropTimer()` (`Blinks/SettingsView.swift:31-33`, `138-140`)
4. **`@AppStorage`** automatically persists to `UserDefaults` — survives app restart

### Pause/Resume Path

1. **User clicks Pause** in menu → `togglePause()` (`Blinks/AppDelegate.swift:150`)
2. **`isPaused` toggles** — persisted via `@AppStorage("isPaused")`
3. **If paused:** both timers invalidated and nilled, `nextEyeDropTime` cleared
4. **If resumed:** `startBlinkTimer()` and `startEyeDropTimer()` called fresh

## State Management

**Mechanism:** `@AppStorage` in `AppDelegate` — all 8 settings are `UserDefaults`-backed:

| Key | Type | Default | File |
|-----|------|---------|------|
| `blinkInterval` | `Double` | 60.0 | `AppDelegate.swift:13` |
| `blinkDuration` | `Double` | 1.0 | `AppDelegate.swift:14` |
| `blinkOpacity` | `Double` | 0.5 | `AppDelegate.swift:15` |
| `eyeDropInterval` | `Double` | 1800.0 | `AppDelegate.swift:16` |
| `eyeDropSnoozeDuration` | `Double` | 300.0 | `AppDelegate.swift:17` |
| `eyeDropEnabled` | `Bool` | true | `AppDelegate.swift:18` |
| `launchAtLogin` | `Bool` | false | `AppDelegate.swift:19` |
| `isPaused` | `Bool` | false | `AppDelegate.swift:20` |

Additional runtime-only state (not persisted):
- `nextEyeDropTime: Date?` — displayed in menu bar, cleared on sleep/pause (`AppDelegate.swift:22`)

**SwiftUI binding pattern:** `SettingsView` receives `AppDelegate` as `@ObservedObject`, then binds directly to `@AppStorage` properties with `$` prefix for two-way binding.

## Window Hierarchy and Display Management

### Blink Window (`Blinks/BlinkWindow.swift`)

- **Type:** `NSWindow` (not `NSPanel` despite CLAUDE.md description — code uses `NSWindow`)
- **Level:** `.screenSaver` (appears above all windows including full-screen apps)
- **Style:** `.borderless, .fullSizeContentView` — no chrome, full screen coverage
- **Multi-display:** Iterates `NSScreen.screens`, creates one window per screen (`BlinkWindow.swift:16-21`)
- **Collection behavior:** `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`
- **Mouse:** `ignoresMouseEvents = true` — clicks pass through
- **Animation:** `NSAnimationContext` group — 150ms fade-in, hold `blinkDuration`, 150ms fade-out, close

### Eye Drop Reminder Window (`Blinks/EyeDropReminderWindow.swift`)

- **Type:** `NSWindow`
- **Level:** `.floating` (stays on top of normal windows)
- **Style:** `.titled, .fullSizeContentView` — has title bar
- **Size:** 450x340, centered
- **Interaction:** Requires user action (Done or Snooze) to dismiss

### Settings Window (`Blinks/AppDelegate.swift:124-140`)

- **Type:** `NSWindow` with `NSHostingController`
- **Style:** `.titled, .closable, .miniaturizable`
- **Size:** 400x630, centered
- **Toggle behavior:** `toggleSettings()` closes if already open, creates new if closed

## Timer/Scheduler Architecture

### Blink Timer

- **Method:** `startBlinkTimer()` at `AppDelegate.swift:201`
- **Type:** Repeating `Timer.scheduledTimer`
- **Interval:** `blinkInterval` (default 60s, range 30-300s)
- **Tolerance:** `blinkInterval * 0.1` (10% of interval) — `AppDelegate.swift:209`
- **Guard:** Checks `isPaused` before scheduling and `CGDisplayIsAsleep` before showing

### Eye Drop Timer

- **Method:** `startEyeDropTimer()` at `AppDelegate.swift:241`
- **Type:** Repeating `Timer.scheduledTimer`
- **Interval:** `eyeDropInterval` (default 1800s / 30min, range 300-7200s)
- **Tolerance:** `min(eyeDropInterval * 0.1, 60.0)` — capped at 60s — `AppDelegate.swift:250`
- **Guard:** Checks `isPaused && eyeDropEnabled`

### Snooze Timer

- **Method:** `snoozeEyeDropReminder()` at `AppDelegate.swift:276`
- **Type:** One-shot `Timer.scheduledTimer` (`repeats: false`)
- **Interval:** `eyeDropSnoozeDuration` (default 300s / 5min, range 60s-maxSnooze)
- **Tolerance:** `min(eyeDropSnoozeDuration * 0.1, 30.0)` — capped at 30s

## Sleep/Wake Handling

**Registration:** `NSWorkspace.willSleepNotification` and `NSWorkspace.didWakeNotification` registered in `applicationDidFinishLaunching` (`AppDelegate.swift:50-62`).

**On Sleep (`systemWillSleep`)** at `AppDelegate.swift:176`:
- Blink timer invalidated and nulled
- Eye drop timer invalidation is **commented out** (lines 180-185) — intentional behavior from a prior refactor

**On Wake (`systemDidWake`)** at `AppDelegate.swift:188`:
- Uses `DispatchQueue.main.async` with `[weak self]` to ensure proper run loop scheduling
- Restarts blink timer if not paused
- Eye drop timer restart is **commented out** (line 195) — matches the commented-out invalidation on sleep

**Deinit:** Removes observer from `NSWorkspace.shared.notificationCenter` (`AppDelegate.swift:26`)

## Architectural Constraints

- **Threading:** Single-threaded — all UI and timer work on main run loop. `DispatchQueue.main.async` used only for sleep-wake restart safety.
- **Global state:** `AppDelegate` is the single source of truth. No other module-level singletons. `@AppStorage` uses `UserDefaults.standard` implicitly.
- **Circular imports:** None — file dependency graph is a strict tree.
- **Menu bar only:** App has `LSUIElement = true` in `Info.plist` — no dock icon, no default window.

## Anti-Patterns

### Centralized God Object

**What happens:** `AppDelegate` (287 lines) handles menu bar, timers, settings sync, sleep/wake, window creation, pause/resume, and state management all in one class.
**Why it's wrong:** Makes the file hard to extend; any change risks affecting unrelated subsystems.
**Do this instead:** Extract timer management into a `BlinkScheduler` class, window management into a `WindowManager`, and keep `AppDelegate` as a thin coordinator. See `Blinks/AppDelegate.swift`.

### Imperative Window Creation

**What happens:** All windows (`Settings`, `BlinkWindow`, `EyeDropReminderWindow`) are created imperatively with `NSWindow(contentViewController:)` and `NSHostingController` rather than using SwiftUI `Window`/`WindowGroup` scenes.
**Why it's wrong:** Misses benefits of SwiftUI lifecycle (automatic state restoration, scene management). Creates orphan window references if not carefully nilled.
**Do this instead:** On macOS 13+, use `@main` `App` with `Window` scenes. See `Blinks/BlinksApp.swift:7-10` (currently only uses a `Settings` scene with `EmptyView`).

### Unused ContentView

**What happens:** `ContentView.swift` exists but is never referenced by any production code. Only appears in its own `#Preview`.
**Why it's wrong:** Dead code adds confusion and maintenance burden.
**Do this instead:** Remove `Blinks/ContentView.swift` or use it as the `Settings` scene root.

## Error Handling

**Strategy:** Guard-based early returns with optional chaining. Errors logged via `print()` only.

**Patterns:**
- `guard !isPaused else { return }` — timer guards (`AppDelegate.swift:202`)
- `guard CGDisplayIsAsleep(...) == 0 else { return }` — display-asleep guard (`AppDelegate.swift:219`)
- `guard let self = self else { return }` — weak self in closures (`AppDelegate.swift:191`)
- `do/catch` only in `setLaunchAtLogin` for `SMAppService` registration (`AppDelegate.swift:227-236`)

## Cross-Cutting Concerns

**Logging:** `print()` statements only. Used in `setLaunchAtLogin` error reporting (`AppDelegate.swift:234`) and `#Preview` closures.

**Validation:** Minimal. Snooze slider max is dynamically constrained to `min(eyeDropInterval, 1800)` in `SettingsView.swift:168`. No runtime validation of timer values.

**Authentication:** Not applicable — no network or user auth.

**Persistence:** All settings via `@AppStorage` → `UserDefaults`. No file-based or database persistence.

---

*Architecture analysis: 2026-05-15*
