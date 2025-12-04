import SwiftUI
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var blinkTimer: Timer?
    private var eyeDropTimer: Timer?
    private var pauseMenuItem: NSMenuItem?
    
    // Settings with UserDefaults persistence and real-time updates
    @AppStorage("blinkInterval") var blinkInterval: Double = 60.0 // 1 minute in seconds
    @AppStorage("blinkDuration") var blinkDuration: Double = 1.0 // 1.0 second
    @AppStorage("blinkOpacity") var blinkOpacity: Double = 0.5 // 50% transparency
    @AppStorage("eyeDropInterval") var eyeDropInterval: Double = 1800.0 // 30 minutes in seconds
    @AppStorage("eyeDropEnabled") var eyeDropEnabled: Bool = true
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("isPaused") var isPaused: Bool = false
    
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
        menu.addItem(NSMenuItem(title: "Blink Now", action: #selector(blinkNow), keyEquivalent: "b"))
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
        window.setContentSize(NSSize(width: 400, height: 550))
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow = window
    }
    
    @objc func blinkNow() {
        showBlinkAnimation()
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
    
    private func startBlinkTimer() {
        guard !isPaused else { return }
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { [weak self] _ in
            self?.showBlinkAnimation()
        }
    }
    
    func restartBlinkTimer() {
        startBlinkTimer()
    }
    
    private func showBlinkAnimation() {
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
        eyeDropTimer = Timer.scheduledTimer(withTimeInterval: eyeDropInterval, repeats: true) { [weak self] _ in
            self?.showEyeDropReminder()
        }
    }
    
    func restartEyeDropTimer() {
        startEyeDropTimer()
    }
    
    private func showEyeDropReminder() {
        let reminderWindow = EyeDropReminderWindow(
            onDone: { [weak self] in
                // User marked as done, just restart the normal timer
                self?.restartEyeDropTimer()
            },
            onSnooze: { [weak self] in
                // Snooze for 5 minutes
                self?.snoozeEyeDropReminder()
            }
        )
        reminderWindow.show()
    }
    
    private func snoozeEyeDropReminder() {
        eyeDropTimer?.invalidate()
        eyeDropTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            self?.showEyeDropReminder()
        }
    }
}
