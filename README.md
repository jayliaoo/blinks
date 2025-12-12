# Blinks - Eye Rest Reminder for macOS

A native macOS menu bar application designed to reduce eye strain by periodically reminding you to blink and take breaks. It features a subtle full-screen blink animation and a dedicated eye drop reminder system.

## Features

### 👁️ Blink Reminder

- **Full-Screen Animation**: A periodic, gentle full-screen blink animation that mimics the closing of eyes.
- **Customizable Interval**: Set reminders every 0.5 to 5 minutes.
- **Adjustable Duration**: Control how long the blink lasts (0.5 to 5.0 seconds).
- **Opactity Control**: detailed control over the darkness of the blink (10% to 100%).
- **Visual Cue**: Displays "Blink Your Eyes!" during the animation to reinforce the habit.

### 💧 Eye Drop Reminder

- **Dedicated Timer**: Separate configurable timer for eye drops (5 to 120 minutes).
- **Forced Interaction**: The reminder window stays on top and cannot be closed without action, ensuring you don't accidentally ignore it.
- **Smart Snooze**: Snooze the reminder for a short duration (configurable up to 30 mins) if you're in the middle of a task.
- ** synchronized Pausing**: Pausing the main blink reminder also pauses the eye drop timer.

### ⚙️ Application Control

- **Menu Bar Request**: unobtrusive icon in the macOS menu bar.
- **Pause/Resume**: Quickly toggle all functionality with `Cmd+P` or via the menu (useful for meetings or movies).
- **Launch at Login**: Option to automatically start the app when you sign in (requires macOS 13+).
- **Multi-Display Support**: The blink animation covers all connected displays.
- **Battery Friendly**: Efficient native Swift implementation.

## Requirements

- macOS 13.0 or later (for Launch at Login support).
- Xcode 15.0+ (to build from source).

## Quick Start

### Building and Running

1.  **Clone and Open**:

    ```bash
    git clone https://github.com/jayliaoo/blinks.git
    cd blinks
    open Blinks.xcodeproj
    ```

    _Alternatively, verify the integrity of the build script:_ `cat build.sh`

2.  **Build**:
    Select the "Blinks" scheme in Xcode and press `Cmd + R` to run.

3.  **Use**:
    Look for the eye icon (👁️) in your menu bar.

### Configuration

Click the menu bar icon and select **Settings** (`Cmd + S`) to customize:

- **Blink Interval**: Frequency of the full-screen blink.
- **Blink Duration**: Length of the animation.
- **Opacity**: Darkness level of the overlay.
- **Eye Drop Reminder**: Toggle and configure the interval (5-120 mins) and snooze duration.
- **Launch at Login**: Auto-start preference.

## Troubleshooting

- **Blink Overlay Not Appearing**: Ensure "Blinks" is enabled in **System Settings > Privacy & Security > Screen Recording**. This permission is required to draw over other windows.
- **Menu Icon Missing**: If you have many menu bar apps, the icon might be hidden by the notch on newer MacBooks. Try closing other apps.

## Key Shortcuts

- **`Cmd + S`**: Open Settings
- **`Cmd + P`**: Pause/Resume All Reminders
- **`Cmd + Q`**: Quit Application

## Technical Details

**Architecture**:

- **Language**: Swift 5
- **UI Framework**: SwiftUI (Settings & Reminders) + AppKit (Window Management)
- **State Management**: `ObservableObject` pattern in `AppDelegate` for real-time setting updates.
- **Storage**: `UserDefaults` for lightweight persistence.

**Project Structure**:

```text
blinks/
├── Blinks/
│   ├── AppDelegate.swift        # Main logic & menu bar management
│   ├── SettingsView.swift       # SwiftUI configuration screen
│   ├── BlinkWindow.swift        # The overlay animation window
│   ├── EyeDropReminderWindow.swift # The floating reminder window
│   └── BlinksApp.swift          # App entry point
├── Blinks.xcodeproj/            # Xcode project files
└── build.sh                     # CLI build script
```

## Contributing

Messages and pull requests are welcome. This project is open for personal and commercial use to promote eye health.

## License

MIT License.
