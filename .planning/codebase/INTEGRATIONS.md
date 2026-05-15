# External Integrations

**Analysis Date:** 2026-05-15

## APIs & External Services

**None detected.** This application has zero external service dependencies. All functionality is implemented using local macOS system APIs only. No network calls, no REST APIs, no third-party SDKs.

## Data Storage

**Databases:**
- None

**File Storage:**
- `UserDefaults` — All app settings persisted via `@AppStorage` keys (`AppDelegate.swift:13-20`):
  - `blinkInterval` (Double, default 60.0)
  - `blinkDuration` (Double, default 1.0)
  - `blinkOpacity` (Double, default 0.5)
  - `eyeDropInterval` (Double, default 1800.0)
  - `eyeDropSnoozeDuration` (Double, default 300.0)
  - `eyeDropEnabled` (Bool, default true)
  - `launchAtLogin` (Bool, default false)
  - `isPaused` (Bool, default false)

**Caching:**
- None

## Authentication & Identity

**Auth Provider:**
- None — The app has no authentication, no user accounts, no cloud identity.

## Notification & System Event Integrations

**Sleep/Wake Notifications:**
- Registered via `NSWorkspace.shared.notificationCenter` (`AppDelegate.swift:50-62`)
- `NSWorkspace.willSleepNotification` — Triggers `systemWillSleep()` to invalidate blink timer and clean up eye drop state (`AppDelegate.swift:176-186`)
- `NSWorkspace.didWakeNotification` — Triggers `systemDidWake()` on main async queue to restart timers after wake (`AppDelegate.swift:188-198`)
- Observer removed in `deinit` (`AppDelegate.swift:26`)

**Display State Detection:**
- `CGDisplayIsAsleep(CGMainDisplayID())` — CoreGraphics call to skip blink animation when display is asleep (`AppDelegate.swift:219`)

**Menu Bar Status Item:**
- `NSStatusBar.system.statusItem(withLength: .variableLength)` — Creates menu bar icon using SF Symbol `eye.fill` (`AppDelegate.swift:32,35`)
- `NSMenu` + `NSMenuDelegate` for dynamic menu updates on open (`AppDelegate.swift:67-92`, `menuWillOpen` at line 95)

**Launch at Login:**
- `SMAppService.mainApp.register()` / `SMAppService.mainApp.unregister()` — macOS 13+ ServiceManagement API (`AppDelegate.swift:226-236`)
- Gated behind `#available(macOS 13.0, *)` check
- Toggled via settings UI binding (`SettingsView.swift:190-200`)

**App Activation:**
- `NSApp.activate(ignoringOtherApps: true)` — Brings app to front when opening settings or showing eye drop reminder (`AppDelegate.swift:137`, `EyeDropReminderWindow.swift:42`)

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- `print()` statements only — used for error logging in `setLaunchAtLogin` catch block (`AppDelegate.swift:234`)

## CI/CD & Deployment

**Hosting:**
- Distributed as standalone `.app` or `.dmg` — no app store or web hosting

**CI Pipeline:**
- None detected — No GitHub Actions workflows, no `.github/workflows/` directory
- Build script `/build.sh` provides manual build automation:
  1. `xcodebuild archive` with ad-hoc signing (`build.sh:25-33`)
  2. `xcodebuild -exportArchive` with `exportOptions.plist` (`build.sh:36-40`)
  3. Optional `hdiutil create` for DMG packaging (`build.sh:60-63`)

## Screen Recording / Accessibility Permissions

**Screen Recording:**
- The app creates overlay windows at `.screenSaver` level — this requires Screen Recording permission on macOS for the overlay to render above other applications
- Not declared in entitlements; granted via System Settings > Privacy & Security > Screen Recording

**App Sandbox:**
- **Disabled** — `com.apple.security.app-sandbox = false` in `Blinks.entitlements:6`
- This is intentional: menu bar overlay windows at `.screenSaver` level require unsandboxed access

**Apple Events:**
- Entitlement enabled: `com.apple.security.automation.apple-events = true` in `Blinks.entitlements:8`
- Likely used for `NSApp.activate(ignoringOtherApps:)` and workspace notifications

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Environment Configuration

**Required env vars:**
- None — The app does not read environment variables

**Secrets:**
- None — No API keys, tokens, or credentials

## Entitlements Summary

| Entitlement | Value | Purpose |
|---|---|---|
| `com.apple.security.app-sandbox` | `false` | Required for screenSaver-level overlay windows |
| `com.apple.security.automation.apple-events` | `true` | Required for app activation and workspace integration |

## Info.plist Key Entries

| Key | Value | Purpose |
|---|---|---|
| `LSUIElement` | `true` | Menu bar only app — no dock icon, no menu bar UI |

---

*Integration audit: 2026-05-15*
