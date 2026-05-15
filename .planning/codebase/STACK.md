# Technology Stack

**Analysis Date:** 2026-05-15

## Languages

**Primary:**
- Swift 5.0 — All application source code (6 Swift files in `Blinks/` target)

**Secondary:**
- Shell (bash) — Build script at `/build.sh`

## Runtime

**Environment:**
- macOS 13.0+ (Ventura or later) — set via `MACOSX_DEPLOYMENT_TARGET` in `Blinks.xcodeproj/project.pbxproj:209,266`

**Package Manager:**
- None — No third-party dependency managers detected. No `Package.swift`, `Cartfile`, `Podfile`, or `Package.resolved` present.
- Zero external dependencies.

## Frameworks

**Core:**
- SwiftUI — Primary UI framework for settings panel (`SettingsView.swift`), eye drop reminder view (`EyeDropReminderView` in `EyeDropReminderWindow.swift`), blink overlay view (`BlinkView` in `BlinkWindow.swift`), and app entry point (`BlinksApp.swift`)
- AppKit — Window management and menu bar via `NSWindow`, `NSPanel`, `NSStatusBar`, `NSMenu`, `NSHostingController`. Used in `AppDelegate.swift`, `BlinkWindow.swift`, `EyeDropReminderWindow.swift`
- ServiceManagement — Launch-at-login via `SMAppService.mainApp.register()/unregister()` (`AppDelegate.swift:226-236`)

**Testing:**
- None — No test files or test configuration detected. `#Preview` macros are used inline in `SettingsView.swift:241`, `ContentView.swift:13`, `EyeDropReminderWindow.swift:151` for SwiftUI previews only.

**Build/Dev:**
- Xcode 15.0+ (`Blinks.xcodeproj`) — Primary IDE
- `xcodebuild` — CLI build tool, used in `/build.sh:25-33` for archiving and `/build.sh:36-40` for export
- `hdiutil` — DMG packaging in `/build.sh:60-63`
- Export options in `/exportOptions.plist` — `mac-application` method, automatic signing

## Key Dependencies

**Critical:**
- None — This project has zero third-party packages. All functionality uses Apple system frameworks only.

**Infrastructure (System Frameworks):**
- `SwiftUI` — All views and state management
- `AppKit` — Window creation, menu bar, status item, cursor, workspace notifications
- `ServiceManagement` — `SMAppService` for launch-at-login (macOS 13+ API)
- `CoreGraphics` (implicit) — `CGDisplayIsAsleep()` and `CGMainDisplayID()` for display sleep detection (`AppDelegate.swift:219`)

## Architecture Patterns

**SwiftUI + AppKit Hybrid:**
- Entry point uses `@main` with `SwiftUI App` protocol (`BlinksApp.swift:3-4`)
- `AppDelegate` adopts `NSApplicationDelegate` AND `ObservableObject` for dual lifecycle + state roles (`AppDelegate.swift:4`)
- `@NSApplicationDelegateAdaptor(AppDelegate.self)` injects AppDelegate into SwiftUI app lifecycle (`BlinksApp.swift:5`)
- `NSHostingController` bridges SwiftUI views into AppKit windows (`AppDelegate.swift:127`, `EyeDropReminderWindow.swift:26`, `BlinkWindow.swift:25`)

**State Management:**
- `@AppStorage` for all persistent settings — backs directly into `UserDefaults` (`AppDelegate.swift:13-20`)
- `@ObservedObject` to pass AppDelegate instance into SwiftUI views (`SettingsView.swift:4`)
- `@State` not used — no local mutable view state; all state lives in AppDelegate

**Window Management:**
- Blink window: `NSWindow` with `.borderless` + `.fullSizeContentView` style, `.screenSaver` level, `.canJoinAllSpaces` + `.fullScreenAuxiliary` + `.stationary` collection behavior (`BlinkWindow.swift:28-34`)
- Eye drop reminder: `NSWindow` with `.titled` + `.fullSizeContentView` style, `.floating` level (`EyeDropReminderWindow.swift:30-31`)
- Settings window: `NSWindow` with `.titled` + `.closable` + `.miniaturizable` style (`AppDelegate.swift:131`)

**Timer Strategy:**
- `Timer.scheduledTimer` with `[weak self]` closures for both blink and eye-drop cycles (`AppDelegate.swift:205`, `AppDelegate.swift:246`)
- Tolerance set to 10% of interval for power efficiency (`AppDelegate.swift:209`, `AppDelegate.swift:250`)
- Timers invalidated before recreation (`AppDelegate.swift:203-204`, `AppDelegate.swift:243-244`)

## Configuration

**Environment:**
- All settings persisted via `UserDefaults` keys: `blinkInterval`, `blinkDuration`, `blinkOpacity`, `eyeDropInterval`, `eyeDropSnoozeDuration`, `eyeDropEnabled`, `launchAtLogin`, `isPaused` (`AppDelegate.swift:13-20`)
- No `.env` files, no external configuration

**Build:**
- `Blinks.xcodeproj` — Xcode project file
- `/build.sh` — Shell script for release archive + export + optional DMG
- `/exportOptions.plist` — Export configuration for `xcodebuild -exportArchive`
- Bundle ID: `com.blinks.app` (`project.pbxproj:295`)
- Marketing version: `1.0` (`project.pbxproj:294`)
- Build version: `1` (`project.pbxproj:282`)

## Platform Requirements

**Development:**
- macOS 13.0+ host
- Xcode 15.0+
- Apple developer signing identity (automatic for development)

**Production:**
- macOS 13.0+ target machines
- Code signing via ad-hoc (`CODE_SIGN_IDENTITY="-"`) or automatic signing
- App sandbox disabled (`Blinks.entitlements:6` — `com.apple.security.app-sandbox = false`)
- Apple Events entitlement enabled (`Blinks.entitlements:8` — `com.apple.security.automation.apple-events = true`)
- `LSUIElement = true` in Info.plist — runs as menu bar app without dock icon (`Info.plist:23-24`)

---

*Stack analysis: 2026-05-15*
