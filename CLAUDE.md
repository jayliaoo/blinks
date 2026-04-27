# Blinks - Claude AI Assistant Guide

This document provides essential information for Claude and other AI assistants working on the Blinks macOS application.

## Project Overview

Blinks is a macOS menu bar application that helps reduce eye strain through:
- Full-screen blink animation reminders
- Eye drop reminder system with snooze functionality
- Menu bar interface with customizable settings
- Launch at login support

**Technology Stack:**
- Language: Swift 5
- UI Framework: SwiftUI (Settings & Reminders) + AppKit (Window Management)
- Minimum macOS Version: 13.0
- Build Tool: Xcode 15.0+

## Build Commands

```bash
# Open in Xcode (recommended)
open Blinks.xcodeproj

# Build via CLI
xcodebuild -project Blinks.xcodeproj -scheme Blinks -configuration Debug build

# Build for release
xcodebuild -project Blinks.xcodeproj -scheme Blinks -configuration Release build

# Clean build folder
xcodebuild clean -project Blinks.xcodeproj -scheme Blinks
```

## Project Structure

```
Blinks/
├── BlinksApp.swift              # App entry point (@main)
├── AppDelegate.swift            # Core logic: timers, menu bar, sleep/wake handling
├── SettingsView.swift           # SwiftUI settings panel with @AppStorage
├── BlinkWindow.swift            # Full-screen overlay window (NSWindow)
├── EyeDropReminderWindow.swift  # Floating eye drop reminder window
├── ContentView.swift            # Basic content view
├── Info.plist                   # App configuration
└── Blinks.entitlements          # App sandbox permissions
```

## Key Implementation Patterns

### State Management
- `AppDelegate` uses `ObservableObject` for centralized state
- `@AppStorage` for UserDefaults-backed settings (automatic persistence)
- `@ObservedObject` to inject AppDelegate into SwiftUI views

### Timer Handling
```swift
// Always set tolerance for power efficiency
timer.tolerance = interval * 0.1

// Invalidate before creating new timers
blinkTimer?.invalidate()
blinkTimer = Timer.scheduledTimer(...)

// Use [weak self] in closures
Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
    self?.showBlink()
}
```

### Sleep/Wake Handling
- Register for `NSWorkspace.willSleepNotification` and `didWakeNotification`
- Store scheduled times for continuity across sleep
- Invalidate timers on sleep, restart on wake

### Window Management
- Use `NSPanel` for overlay windows
- Set `level = .screenSaver` to appear above everything
- Multi-display support via `NSScreen.screens`

## Code Style Guidelines

### Naming Conventions
- Types: PascalCase (`AppDelegate`, `BlinkWindow`)
- Functions/Variables: camelCase (`startBlinkTimer()`, `eyeDropInterval`)
- Private members: Use `private` keyword explicitly

### SwiftUI Conventions
- Use `some View` for view body returns
- `@StateObject` for owned state, `@ObservedObject` for injected
- `@AppStorage` for persistent settings

### Memory Management
- Always use `[weak self]` in closure-based callbacks
- Invalidate timers in `deinit` and on system sleep
- Set window references to `nil` after closing

### Error Handling
- Use `guard` for early returns
- Use `if let` / `guard let` for optional unwrapping
- Log errors with `print()` for debugging

## Common Tasks

### Adding a New Setting
1. Add `@AppStorage("keyName")` property in `AppDelegate`
2. Add UI control in `SettingsView.swift`
3. Use `didSet` or `onChange` to react to changes

### Modifying Timer Behavior
1. Locate timer in `AppDelegate.swift`
2. Invalidate existing timer before changes
3. Restart with new parameters
4. Handle pause/resume state

### Changing UI Elements
- Settings UI: Modify `SettingsView.swift`
- Blink animation: Modify `BlinkWindow.swift`
- Eye drop reminder: Modify `EyeDropReminderWindow.swift`

## Key Files Explained

### AppDelegate.swift
Central coordinator that manages:
- Menu bar status item
- Blink and eye drop timers
- Sleep/wake notifications
- Pause/resume state
- Settings synchronization

### BlinkWindow.swift
Full-screen overlay that:
- Creates transparent `NSPanel` covering all screens
- Animates opacity for "blink" effect
- Shows "Blink Your Eyes!" message

### EyeDropReminderWindow.swift
Floating reminder that:
- Stays on top of all windows
- Offers "Done" and "Snooze" buttons
- Cannot be dismissed without action

### SettingsView.swift
SwiftUI settings panel with:
- Blink interval/duration/opacity sliders
- Eye drop timer configuration
- Launch at login toggle

## Troubleshooting

### Blink Overlay Not Appearing
- Check Screen Recording permission in System Settings
- Verify `level = .screenSaver` is set on window

### Timer Issues
- Ensure timers are invalidated before recreation
- Check `isPaused` state
- Verify tolerance is set for power efficiency

### Memory Leaks
- Ensure `[weak self]` in all closures
- Check timer invalidation in `deinit`

## Notes for AI Assistants

1. **Always read existing code first** before making changes to understand patterns
2. **Test builds** after modifications using xcodebuild
3. **Preserve existing patterns** when extending functionality
4. **Use meaningful commit messages** if committing changes
5. **No tests exist** in this project - manual testing required
6. **Code signing** is handled by Xcode automatically for development
7. **Keep UI changes minimal** unless explicitly requested

---

For detailed agent guidelines, also see `AGENTS.md` in this repository.