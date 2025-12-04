# Blinks - Eye Rest Reminder for macOS

A native macOS menu bar application that periodically displays a full-screen blink animation to remind you to rest your eyes.

## Features

- 🎯 **Menu Bar App**: Lives in your menu bar, stays out of your way
- ⏰ **Configurable Interval**: Set how often you want to be reminded (0.5-5 minutes)
- ⚡ **Adjustable Duration**: Control how long the blink lasts (0.5-5.0 seconds)
- 🌓 **Custom Opacity**: Set the transparency of the blink (10-100%)
- 💬 **Visual Reminder**: "Blink Your Eyes!" text appears during the animation
- 💧 **Eye Drop Reminder**: Configurable reminders to use eye drops (1-120 minutes)
  - Interactive popup with Done and Snooze (configurable duration) options
  - Synchronized with blink reminder pause state
- ⏸️ **Pause/Resume**: Temporarily pause reminders when you need to focus
- 🚀 **Launch at Login**: Automatically start when you log in
- 🖥️ **Multi-Display Support**: Works across all connected displays
- ✨ **Smooth Animations**: Gentle fade in/out effects

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)

## Quick Start

### Building and Running

1. Open the project in Xcode:

   ```bash
   open Blinks.xcodeproj
   # or run: ./build.sh
   ```

2. Select the "Blinks" scheme and press `Cmd + R` to build and run

3. Look for the **eye icon (👁️)** in your menu bar

### Configuration

Click the eye icon and select "Settings" to configure:

- **Blink Interval**: How often the blink appears (0.5-5 minutes, default: 1 minute)
- **Blink Duration**: How long the blink lasts (0.5-5.0 seconds, default: 1.0 second)
- **Opacity**: How dark the blink is (10-100%, default: 50%)
- **Eye Drop Reminder**: Enable/disable eye drop reminders (default: enabled)
  - **Reminder Interval**: How often to remind you to use eye drops (1-120 minutes, default: 30 minutes)
  - **Snooze Duration**: How long to delay when snoozed (1 minute to interval-1, default: 5 minutes)
- **Launch at Login**: Enable to start automatically when you log in

### Menu Options

- **Settings** (Cmd+S): Open the settings window
- **Pause/Resume** (Cmd+P): Temporarily stop or restart both blink and eye drop reminders
- **Quit** (Cmd+Q): Exit the application

## Recommended Settings

### For Intensive Work (Frequent Breaks)

- **Interval**: 1-2 minutes
- **Duration**: 1.0-2.0 seconds
- **Opacity**: 60-80%

### For Normal Work (Regular Reminders)

- **Interval**: 2-3 minutes
- **Duration**: 1.0-1.5 seconds
- **Opacity**: 50-70%

### For Light Work (Gentle Reminders)

- **Interval**: 4-5 minutes
- **Duration**: 0.5-1.0 seconds
- **Opacity**: 30-50%

## Distribution

### For Personal Use

1. Build the app (Cmd + R)
2. In Finder, go to: `~/Library/Developer/Xcode/DerivedData/Blinks-*/Build/Products/Debug/`
3. Copy `Blinks.app` to your Applications folder

### For Sharing

1. In Xcode, select **Product > Archive**
2. Click **Distribute App** > **Copy App**
3. Select a location to save
4. Share the .app bundle

## Troubleshooting

### The blink doesn't appear

1. Go to **System Settings > Privacy & Security > Screen Recording**
2. Enable **Blinks**
3. Restart the app

### Can't find the menu bar icon

1. Check if the menu bar is full (macOS hides icons when space is limited)
2. Quit some other menu bar apps to free up space
3. Restart Blinks

### Launch at login doesn't work

1. Go to **System Settings > General > Login Items**
2. Look for **Blinks** in the list
3. Toggle the setting off and on again in the app

### Settings don't save

1. Try quitting and relaunching the app
2. Check Console.app for any error messages

## Testing

1. **Basic Functionality**:

   - Enable eye drop reminders
   - Set interval to 5 minutes (minimum)
   - Wait for reminder to appear
   - Test both Done and Snooze buttons

2. **Pause Integration**:

   - Enable both reminders
   - Pause using menu bar
   - Verify no reminders appear
   - Resume and verify both work

3. **Settings Persistence**:
   - Change eye drop interval
   - Quit and relaunch app
   - Verify settings are preserved

## Technical Details

### Architecture

The app is built with:

- **SwiftUI**: Modern declarative UI framework for the settings interface
- **AppKit**: Native macOS framework for menu bar and window management
- **ServiceManagement**: For launch at login functionality
- **UserDefaults**: Persistent storage for user preferences

### Key Components

- `BlinksApp.swift`: App entry point
- `AppDelegate.swift`: Menu bar management, timer logic, and ObservableObject for real-time updates
- `SettingsView.swift`: SwiftUI settings interface with live value updates
- `BlinkWindow.swift`: Full-screen overlay window with fade animations
- `EyeDropReminderWindow.swift`: Interactive eye drop reminder popup

### Project Structure

```
blinks/
├── README.md                    # This file
├── build.sh                     # Build helper script
├── Blinks.xcodeproj/            # Xcode project
└── Blinks/                      # Source code
    ├── BlinksApp.swift          # App entry point
    ├── AppDelegate.swift        # Core logic
    ├── SettingsView.swift       # Settings UI
    ├── BlinkWindow.swift        # Blink overlay
    ├── EyeDropReminderWindow.swift  # Eye drop reminder popup
    ├── Info.plist               # App configuration
    ├── Blinks.entitlements      # App permissions
    └── Assets.xcassets/         # App icon and assets
```

### Data Flow

```
User → Menu Bar → AppDelegate (ObservableObject)
                       ↓
                  SettingsView (@ObservedObject)
                       ↓
                  Real-time Updates
                       ↓
                  Timer → BlinkWindow
                       ↓
                  Full Screen Overlay
```

### Settings Persistence

All settings are stored in UserDefaults:

- `blinkInterval`: Time between blinks (30-300 seconds)
- `blinkDuration`: How long each blink lasts (0.5-5.0 seconds)
- `blinkOpacity`: Transparency level (0.1-1.0)
- `eyeDropInterval`: Time between eye drop reminders (60-7200 seconds)
- `eyeDropSnoozeDuration`: Snooze delay duration (60 seconds to interval-60)
- `eyeDropEnabled`: Whether eye drop reminders are enabled (boolean)
- `launchAtLogin`: Whether to start at login (boolean)
- `isPaused`: Pause state (boolean)

### Timer Logic

1. **Normal Operation**: Timer fires every `eyeDropInterval` seconds
2. **On Done**: Restarts normal timer
3. **On Snooze**: Creates one-time timer for the configured snooze duration
4. **On Pause**: Both blink and eye drop timers are invalidated
5. **On Resume**: Both timers restart with their configured intervals

### Permissions Required

- **Screen Recording**: For full-screen overlay (automatically requested on first blink)
- **Login Items**: For launch at login (requested when user enables the feature)

## Customization

### Changing the Blink Color

In `BlinkWindow.swift`, modify:

```swift
Rectangle()
    .fill(Color.black.opacity(opacity))
```

To any color you prefer:

```swift
Rectangle()
    .fill(Color.blue.opacity(opacity))  // or any color
```

### Other Customization Ideas

- Add sound effects
- Show custom messages during the blink
- Add different animation styles
- Integrate with other health apps

## Recent Updates

### December 4, 2025 - Eye Drop Reminder

- **New Feature**: Eye drop reminder functionality
  - Configurable interval (1-120 minutes, default: 30 minutes)
  - Interactive popup window with Done and Snooze buttons
  - Snooze delays the reminder by 5 minutes
  - Enable/disable toggle in settings
  - Synchronized with blink reminder pause state
- **UI Improvements**: Modern gradient design for eye drop reminder popup
- **Settings Window**: Expanded to accommodate new eye drop settings

### December 3, 2025 - Core Features

### Real-Time Value Display

- Settings values now update in real-time as sliders are moved
- Made `AppDelegate` conform to `ObservableObject`
- Updated `SettingsView` to use `@ObservedObject` for live updates

### Pause/Resume Feature

- Added ability to pause and resume blink reminders (Cmd+P)
- Pause state persists across app restarts
- Menu item text changes dynamically based on state

### Updated Ranges

- **Interval**: Changed from 1-60 minutes to 0.5-5 minutes (more frequent reminders)
- **Duration**: Changed from 0.1-3.0 seconds to 0.5-5.0 seconds (better visibility)
- Values display in semibold font for better readability

### Visual Improvements

- Added "Blink Your Eyes!" text overlay during blink animation
- Large, bold text (72pt) with subtle shadow
- Decimal interval display (e.g., "1.5 min" instead of "1 min")

### App Icon

- Professional app icon with eye symbol
- Vibrant blue-to-purple gradient background
- All required sizes for macOS (16x16 to 1024x1024)

## Future Enhancements

1. **Multiple Snooze Options**: Quick buttons for 5, 10, 15 minutes
2. **Usage Statistics**: Track how often eye drops are used
3. **Custom Messages**: Allow users to customize reminder text
4. **Sound Notifications**: Optional audio alert
5. **History Log**: Keep track of when eye drops were used

## License

This project is open source and available for personal and commercial use.

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

Built with ❤️ using Swift and SwiftUI for macOS.
