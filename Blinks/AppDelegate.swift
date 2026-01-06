import SwiftUI
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var blinkTimer: Timer?
    private var eyeDropTimer: Timer?
    private var eyeDropReminderWindow: EyeDropReminderWindow?
    private var pauseMenuItem: NSMenuItem?
    
    // Settings with UserDefaults persistence and real-time updates
    @AppStorage("blinkInterval") var blinkInterval: Double = 60.0 // 1 minute in seconds
    @AppStorage("blinkDuration") var blinkDuration: Double = 1.0 // 1.0 second
    @AppStorage("blinkOpacity") var blinkOpacity: Double = 0.5 // 50% transparency
    @AppStorage("eyeDropInterval") var eyeDropInterval: Double = 1800.0 // 30 minutes in seconds
    @AppStorage("eyeDropSnoozeDuration") var eyeDropSnoozeDuration: Double = 300.0 // 5 minutes in seconds
    @AppStorage("eyeDropEnabled") var eyeDropEnabled: Bool = true
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("isPaused") var isPaused: Bool = false
    
    deinit {
        // Remove observers when app terminates
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Blinks")
            button.action = #selector(showMenu)
            button.target = self
        }
        
        // Create menu
        updateMenu()
        
        // Start the blink timer if not paused
        if !isPaused {
            startBlinkTimer()
            startEyeDropTimer()
        }
        
        // Register for sleep/wake notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    private func updateMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(toggleSettings), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        
        // Pause/Resume menu item
        let pauseTitle = isPaused ? "Resume" : "Pause"
        pauseMenuItem = NSMenuItem(title: pauseTitle, action: #selector(togglePause), keyEquivalent: "p")
        menu.addItem(pauseMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func showMenu() {
        updateMenu()
    }
    
    @objc func toggleSettings() {
        if let window = settingsWindow, window.isVisible {
            window.close()
            settingsWindow = nil
        } else {
            showSettings()
        }
    }
    
    private func showSettings() {
        let settingsView = SettingsView(appDelegate: self)
        
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Blinks Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 400, height: 630))
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow = window
    }
    
    @objc func blinkNow() {
        showBlinkAnimation()
    }
    
    @objc func testEyeDropReminder() {
        showEyeDropReminder()
    }
    
    @objc func togglePause() {
        isPaused.toggle()
        
        if isPaused {
            // Stop both timers
            blinkTimer?.invalidate()
            blinkTimer = nil
            eyeDropTimer?.invalidate()
            eyeDropTimer = nil
        } else {
            // Resume both timers
            startBlinkTimer()
            startEyeDropTimer()
        }
        
        // Update menu
        updateMenu()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Sleep/Wake Handlers
    
    @objc private func systemWillSleep() {
        // Invalidate timers and set to nil when system sleeps
        blinkTimer?.invalidate()
        blinkTimer = nil
        eyeDropTimer?.invalidate()
        eyeDropTimer = nil
        
        // Close any open eye drop reminder window to prevent stale UI
        eyeDropReminderWindow?.close()
        eyeDropReminderWindow = nil
    }
    
    @objc private func systemDidWake() {
        // Use DispatchQueue to ensure proper run loop scheduling after wake
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Restart timers when system wakes up, if not paused
            if !self.isPaused {
                self.startBlinkTimer()
                self.startEyeDropTimer()
            }
        }
    }

    
    private func startBlinkTimer() {
        guard !isPaused else { return }
        blinkTimer?.invalidate()
        blinkTimer = nil
        let timer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { [weak self] _ in
            self?.showBlinkAnimation()
        }
        // Add tolerance to allow system to optimize power usage
        timer.tolerance = blinkInterval * 0.1
        blinkTimer = timer
    }
    
    func restartBlinkTimer() {
        startBlinkTimer()
    }
    
    private func showBlinkAnimation() {
        // Skip animation if display is off/asleep
        guard CGDisplayIsAsleep(CGMainDisplayID()) == 0 else { return }
        
        let blinkWindow = BlinkWindow(opacity: blinkOpacity, duration: blinkDuration)
        blinkWindow.show()
    }
    
    func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }
    
    // MARK: - Eye Drop Reminder
    
    private func startEyeDropTimer() {
        guard !isPaused && eyeDropEnabled else { return }
        eyeDropTimer?.invalidate()
        eyeDropTimer = nil
        let timer = Timer.scheduledTimer(withTimeInterval: eyeDropInterval, repeats: true) { [weak self] _ in
            self?.showEyeDropReminder()
        }
        // Add tolerance to allow system to optimize power usage
        timer.tolerance = min(eyeDropInterval * 0.1, 60.0) // Max 1 minute tolerance
        eyeDropTimer = timer
    }
    
    func restartEyeDropTimer() {
        startEyeDropTimer()
    }
    
    private func showEyeDropReminder() {
        eyeDropTimer?.invalidate()
        eyeDropReminderWindow = EyeDropReminderWindow(
            onDone: { [weak self] in
                // User marked as done, just restart the normal timer
                self?.eyeDropReminderWindow = nil
                self?.restartEyeDropTimer()
            },
            onSnooze: { [weak self] in
                // Snooze for configured duration
                self?.eyeDropReminderWindow = nil
                self?.snoozeEyeDropReminder()
            }
        )
        eyeDropReminderWindow?.show()
    }
    
    private func snoozeEyeDropReminder() {
        eyeDropTimer?.invalidate()
        eyeDropTimer = nil
        let timer = Timer.scheduledTimer(withTimeInterval: eyeDropSnoozeDuration, repeats: false) { [weak self] _ in
            self?.showEyeDropReminder()
        }
        timer.tolerance = min(eyeDropSnoozeDuration * 0.1, 30.0) // Max 30 seconds tolerance
        eyeDropTimer = timer
    }
}
