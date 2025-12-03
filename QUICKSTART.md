# Quick Start Guide

## 🚀 Getting Started

### 1. Open the Project

The project should now be open in Xcode. If not, run:

```bash
./build.sh
```

### 2. Build and Run

1. In Xcode, select the **Blinks** scheme at the top (next to the play button)
2. Press **Cmd + R** or click the Play button
3. The app will build and launch

### 3. First Launch

- Look for the **eye icon (👁️)** in your menu bar (top-right area)
- If you don't see it, check if your menu bar is full (macOS hides icons when space is limited)

### 4. Configure Settings

1. Click the eye icon in the menu bar
2. Select **"Settings"**
3. Adjust the following:
   - **Blink Interval**: How often to blink (default: 20 minutes)
   - **Blink Duration**: How long the blink lasts (default: 0.5 seconds)
   - **Opacity**: How dark the blink is (default: 50%)
   - **Launch at Login**: Enable to start automatically

### 5. Test It Out

1. Click the eye icon
2. Select **"Blink Now"** to see the effect immediately
3. Adjust settings until you're happy with the behavior

## 📦 Creating a Distributable App

### Option 1: Simple Copy (for personal use)

1. Build the app (Cmd + R)
2. In Finder, go to: `~/Library/Developer/Xcode/DerivedData/Blinks-*/Build/Products/Debug/`
3. Copy `Blinks.app` to your Applications folder
4. Double-click to run

### Option 2: Archive (for distribution)

1. In Xcode, select **Product > Archive**
2. Wait for the archive to complete
3. Click **Distribute App**
4. Choose **Copy App**
5. Select a location to save
6. The app is now ready to share or install

## 🎯 Usage Tips

### Recommended Settings for Eye Health

Based on the 20-20-20 rule:

- **Interval**: 20 minutes (1200 seconds)
- **Duration**: 1-2 seconds
- **Opacity**: 50-70%

### For Subtle Reminders

- **Interval**: 30-60 minutes
- **Duration**: 0.3-0.5 seconds
- **Opacity**: 30-40%

### For Strong Reminders

- **Interval**: 15-20 minutes
- **Duration**: 1-3 seconds
- **Opacity**: 70-100%

## 🔧 Troubleshooting

### The blink doesn't appear

**Solution**: Grant screen recording permission

1. Go to **System Settings > Privacy & Security > Screen Recording**
2. Enable **Blinks**
3. Restart the app

### Can't find the menu bar icon

**Solution**: Check menu bar space

1. Quit some other menu bar apps to free up space
2. Or use an app like **Bartender** to manage menu bar icons
3. Restart Blinks

### Launch at login doesn't work

**Solution**: Check login items

1. Go to **System Settings > General > Login Items**
2. Look for **Blinks** in the list
3. If not there, toggle the setting in the app
4. May need to grant permission when prompted

### Settings don't save

**Solution**: Check app permissions

1. Make sure the app has permission to write to UserDefaults
2. Try quitting and relaunching the app
3. Check Console.app for any error messages

## 🎨 Customization Ideas

### For Developers

You can modify the code to:

- Change the blink color (currently black)
- Add sound effects
- Show a message during the blink
- Add different animation styles
- Integrate with other health apps

### Modifying the Blink Color

In `BlinkWindow.swift`, change:

```swift
Rectangle()
    .fill(Color.black.opacity(opacity))
```

To:

```swift
Rectangle()
    .fill(Color.blue.opacity(opacity))  // or any color
```

## 📱 System Requirements

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later (for building)
- **Architecture**: Intel or Apple Silicon (Universal)

## 🎓 Learning Resources

If you want to understand how the app works:

1. Read `ARCHITECTURE.md` for technical details
2. Check out the Swift files in the `Blinks/` folder
3. Each file is well-commented and focused on a single responsibility

## 💡 Pro Tips

1. **Test before committing**: Use "Blink Now" to test your settings
2. **Start conservative**: Begin with longer intervals and adjust down
3. **Multi-display**: The app automatically covers all your displays
4. **Keyboard shortcut**: The menu items have keyboard shortcuts (Cmd+S for settings, etc.)
5. **Background app**: The app uses minimal resources when idle

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Look at the Console.app for error messages
3. Make sure you're running macOS 13.0 or later
4. Try rebuilding the app from scratch

## 🎉 Enjoy!

You now have a native macOS app to help protect your eyes. Remember to take breaks, blink often, and look away from your screen regularly!
