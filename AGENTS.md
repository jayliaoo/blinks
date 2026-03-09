# Blinks - Agent Guidelines

This document provides guidelines for agentic coding agents working in this repository.

## Project Overview

Blinks is a macOS menu bar application that reminds users to blink their eyes and use eye drops to reduce eye strain. It features:
- Full-screen blink animation overlay
- Eye drop reminder system with snooze functionality
- Menu bar interface with settings
- Launch at login support

## Build & Run Commands

### Building the App
```bash
# Open in Xcode (recommended for development)
open Blinks.xcodeproj

# Or use xcodebuild CLI
xcodebuild -project Blinks.xcodeproj -scheme Blinks -configuration Debug build
```

### Running Tests
This project has no dedicated test suite. If tests are added:
```bash
# Run all tests
xcodebuild test -project Blinks.xcodeproj -scheme Blinks

# Run a single test
xcodebuild test -project Blinks.xcodeproj -scheme Blinks -only-testing:TestTarget/TestClass/testMethod
```

### Code Signing
For development, code signing is handled automatically by Xcode. For distribution, configure signing in the project settings.

### Linting
No formal linter is configured. Follow Swift conventions below.

## Code Style Guidelines

### General Principles
- Keep code concise and readable
- Avoid unnecessary comments (only add if explaining *why*, not *what*)
- Use Swift's type inference where clear
- Prefer `some View` for SwiftUI view return types

### Naming Conventions
- **Classes/Structs**: PascalCase (e.g., `AppDelegate`, `BlinkWindow`)
- **Functions/Methods**: camelCase (e.g., `startBlinkTimer()`, `showEyeDropReminder()`)
- **Variables/Constants**: camelCase (e.g., `blinkTimer`, `eyeDropInterval`)
- **Private members**: Prefix with `_` or use `private` keyword explicitly
- **File names**: PascalCase matching the main type (e.g., `AppDelegate.swift`)

### Imports
```swift
import SwiftUI
import ServiceManagement
// Only import what's needed
```

### Types & Type Safety
- Use value types (`struct`) by default for models
- Use classes (`class`) when reference semantics or NSObject inheritance is needed
- Use `@AppStorage` for UserDefaults-backed properties
- Use `Optional` types (e.g., `Timer?`) instead of force unwrapping
- Avoid implicit unwrapping (`!`) except for `@IBOutlet` and `@NSApplicationDelegateAdaptor`

### SwiftUI Guidelines
- Use `some View` for view body returns
- Prefer `@StateObject` for owned state, `@ObservedObject` for injected state
- Use `@AppStorage` for persistent settings tied to UserDefaults
- Keep views small and composable

### AppKit Guidelines
- Use `[weak self]` in closures to prevent retain cycles
- Invalidate timers in `deinit` or when stopping
- Use `DispatchQueue.main.async` for UI updates from callbacks

### Error Handling
- Use `guard` for early returns on invalid conditions
- Use `if let` / `guard let` for optional unwrapping
- Handle errors with `do-catch` for operations that can fail
- Log errors with `print()` for debugging (no external logging framework)

### Timer Handling
- Always set timer tolerance for power efficiency: `timer.tolerance = interval * 0.1`
- Invalidate timers when pausing or on system sleep
- Store next scheduled time (`Date().timeIntervalSince1970`) for cross-sleep detection
- Use `repeats: true` for recurring timers, `repeats: false` for one-shot

### Memory Management
- Use `[weak self]` in all closure-based callbacks
- Clean up timers in `systemWillSleep` and `deinit`
- Set references to `nil` after closing windows

### Accessibility
- Use `accessibilityDescription` for menu bar items and custom views
- Support system accessibility settings

## Project Structure

```
Blinks/
├── BlinksApp.swift          # App entry point (@main)
├── AppDelegate.swift        # Main logic, timers, menu bar (NSObject)
├── SettingsView.swift       # SwiftUI settings panel
├── BlinkWindow.swift        # Full-screen overlay window (NSWindow)
├── EyeDropReminderWindow.swift # Eye drop reminder window
├── Assets.xcassets/         # App icons and colors
├── Info.plist              # App configuration
└── Blinks.entitlements     # App sandbox permissions
```

## Key Implementation Patterns

### Menu Bar App
- Use `NSStatusBar.system.statusItem(withLength:)`
- Set `statusItem.menu` for dropdown menu

### Timers
- Store timers as optional properties: `private var blinkTimer: Timer?`
- Invalidate before creating new timers
- Check `isPaused` before starting

### Settings Persistence
- Use `@AppStorage("keyName")` for automatic UserDefaults binding
- Define defaults at property declaration

### Sleep/Wake Handling
- Register for `NSWorkspace.willSleepNotification` and `didWakeNotification`
- Store scheduled times for cross-sleep continuity
- Show pending reminders on wake if they were due while asleep

## Useful Commands

```bash
# Clean build folder
xcodebuild clean -project Blinks.xcodeproj -scheme Blinks

# Build for release
xcodebuild -project Blinks.xcodeproj -scheme Blinks -configuration Release build

# Create archive for distribution
# Use Xcode: Product > Archive > Distribute App
```