# Blinks - Eye Rest Reminder for macOS

A native macOS menu bar application that periodically displays a full-screen blink animation to remind you to rest your eyes.

## Features

- 🎯 **Menu Bar App**: Lives in your menu bar, stays out of your way
- ⏰ **Configurable Interval**: Set how often you want to be reminded (1-60 minutes)
- ⚡ **Adjustable Duration**: Control how long the blink lasts (0.1-3.0 seconds)
- 🌓 **Custom Opacity**: Set the transparency of the blink (10-100%)
- 🚀 **Launch at Login**: Automatically start when you log in
- 🖥️ **Multi-Display Support**: Works across all connected displays
- ✨ **Smooth Animations**: Gentle fade in/out effects

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building)

## Building the App

1. Open the project in Xcode:

   ```bash
   open Blinks.xcodeproj
   ```

2. Select the "Blinks" scheme and your Mac as the destination

3. Build and run the app:
   - Press `Cmd + R` to build and run
   - Or select `Product > Run` from the menu

## Usage

### First Launch

When you first launch the app, you'll see an eye icon (👁️) appear in your menu bar.

### Accessing Settings

Click on the eye icon in the menu bar and select "Settings" to configure:

- **Blink Interval**: How often the blink appears (default: 20 minutes)
- **Blink Duration**: How long the blink lasts (default: 0.5 seconds)
- **Opacity**: How dark the blink is (default: 50%)
- **Launch at Login**: Enable to start automatically when you log in

### Menu Options

Right-click (or click) the menu bar icon to access:

- **Settings**: Open the settings window
- **Blink Now**: Trigger a blink immediately (useful for testing)
- **Quit**: Exit the application

## How It Works

The app uses a timer to periodically display a full-screen overlay on all your displays. The overlay:

- Appears with a smooth fade-in animation
- Stays visible for the configured duration
- Fades out smoothly
- Covers all connected displays simultaneously

This gentle interruption helps remind you to:

- Blink more frequently
- Look away from your screen
- Rest your eyes
- Follow the 20-20-20 rule (every 20 minutes, look at something 20 feet away for 20 seconds)

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework for the settings interface
- **AppKit**: Native macOS framework for menu bar and window management
- **ServiceManagement**: For launch at login functionality
- **UserDefaults**: Persistent storage for user preferences

### Key Components

- `BlinksApp.swift`: App entry point
- `AppDelegate.swift`: Menu bar management and timer logic
- `SettingsView.swift`: SwiftUI settings interface
- `BlinkWindow.swift`: Full-screen overlay window with animations

### Permissions

The app requires:

- Screen recording permission (automatically requested on first blink)
- Accessibility features (for full-screen overlay)

## Customization

All settings are stored in UserDefaults and persist between launches:

- `blinkInterval`: Time between blinks (in seconds)
- `blinkDuration`: How long each blink lasts (in seconds)
- `blinkOpacity`: Transparency level (0.0-1.0)
- `launchAtLogin`: Whether to start at login (boolean)

## Troubleshooting

### The blink doesn't appear

1. Check System Settings > Privacy & Security > Screen Recording
2. Make sure Blinks is allowed
3. Restart the app after granting permission

### Launch at login doesn't work

1. Check System Settings > General > Login Items
2. Ensure Blinks is in the list
3. Toggle the setting off and on again in the app

### The app doesn't appear in the menu bar

1. Check if the menu bar is full (macOS hides icons when space is limited)
2. Try quitting and relaunching the app
3. Check Activity Monitor to ensure the app is running

## License

This project is open source and available for personal and commercial use.

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

Built with ❤️ using Swift and SwiftUI for macOS.
