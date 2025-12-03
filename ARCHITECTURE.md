# Blinks App Architecture

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      macOS Menu Bar                          │
│                     ┌───────────────┐                        │
│                     │   👁️ Blinks   │ ← Menu Bar Icon       │
│                     └───────┬───────┘                        │
│                             │                                │
└─────────────────────────────┼────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   AppDelegate   │
                    │                 │
                    │ • Menu Bar Mgmt │
                    │ • Timer Logic   │
                    │ • Settings      │
                    └────┬────────┬───┘
                         │        │
           ┌─────────────┘        └──────────────┐
           ▼                                     ▼
    ┌──────────────┐                    ┌──────────────┐
    │SettingsView  │                    │ BlinkWindow  │
    │              │                    │              │
    │ • Interval   │                    │ • Full Screen│
    │ • Duration   │                    │ • Opacity    │
    │ • Opacity    │                    │ • Animation  │
    │ • Launch     │                    │ • Multi-Disp │
    └──────────────┘                    └──────────────┘
```

## Component Details

### BlinksApp.swift

- Entry point of the application
- Delegates to AppDelegate for menu bar functionality
- Uses SwiftUI App lifecycle

### AppDelegate.swift

**Responsibilities:**

- Creates and manages the menu bar status item
- Handles timer for periodic blinks
- Manages settings persistence via UserDefaults
- Controls launch at login via ServiceManagement

**Key Properties:**

- `statusItem`: NSStatusItem for menu bar
- `blinkTimer`: Timer for periodic blinks
- `blinkInterval`: Time between blinks (60-3600 seconds)
- `blinkDuration`: How long blink lasts (0.1-3.0 seconds)
- `blinkOpacity`: Transparency (0.1-1.0)
- `launchAtLogin`: Auto-start preference

### SettingsView.swift

**SwiftUI Interface:**

- Interval slider (1-60 minutes)
- Duration slider (0.1-3.0 seconds)
- Opacity slider (10-100%)
- Launch at login toggle

**Features:**

- Real-time updates
- Formatted time display
- Callback-based communication with AppDelegate

### BlinkWindow.swift

**Window Management:**

- Creates borderless, full-screen windows
- Covers all connected displays
- Window level: `.screenSaver` (above everything)
- Ignores mouse events (non-intrusive)

**Animation:**

1. Fade in (0.15s)
2. Hold (configurable duration)
3. Fade out (0.15s)
4. Auto-close

## Data Flow

```
User Interaction → Menu Bar Click → AppDelegate
                                         │
                                         ├→ Show Settings Window
                                         │      │
                                         │      └→ User Adjusts Settings
                                         │             │
                                         │             └→ UserDefaults
                                         │                    │
                                         │                    └→ Timer Restart
                                         │
                                         └→ Timer Fires → BlinkWindow
                                                              │
                                                              └→ Full Screen Overlay
                                                                     │
                                                                     └→ Auto Dismiss
```

## Settings Persistence

All settings are stored in UserDefaults:

```swift
@AppStorage("blinkInterval") var blinkInterval: Double = 1200.0
@AppStorage("blinkDuration") var blinkDuration: Double = 0.5
@AppStorage("blinkOpacity") var blinkOpacity: Double = 0.5
@AppStorage("launchAtLogin") var launchAtLogin: Bool = false
```

## Launch at Login

Uses ServiceManagement framework (macOS 13+):

```swift
if enabled {
    try SMAppService.mainApp.register()
} else {
    try SMAppService.mainApp.unregister()
}
```

## Multi-Display Support

The app detects all connected displays and creates a separate window for each:

```swift
let screens = NSScreen.screens
for screen in screens {
    createBlinkWindow(for: screen)
}
```

## Key Features Implementation

### 1. Menu Bar Only App

- `LSUIElement = YES` in Info.plist
- No dock icon
- Lives only in menu bar

### 2. Periodic Blinks

- `Timer.scheduledTimer` with configurable interval
- Automatically repeats
- Restarts when interval changes

### 3. Full Screen Overlay

- Borderless window
- Screen saver level (above all windows)
- Transparent background
- Ignores mouse events

### 4. Smooth Animations

- NSAnimationContext for fade effects
- 0.15s fade in/out
- Configurable hold duration

### 5. Settings Persistence

- UserDefaults for automatic persistence
- @AppStorage property wrapper
- Immediate updates

## Build Configuration

- **Minimum macOS**: 13.0 (Ventura)
- **Swift Version**: 5.0
- **Frameworks**: SwiftUI, AppKit, ServiceManagement
- **Entitlements**: Automation (for login items)
- **Bundle ID**: com.blinks.app
