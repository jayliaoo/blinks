import SwiftUI
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?
    private var blinkTimer: Timer?
    
    // Settings with UserDefaults persistence
    @AppStorage("blinkInterval") private var blinkInterval: Double = 1200.0 // 20 minutes in seconds
    @AppStorage("blinkDuration") private var blinkDuration: Double = 0.5 // 0.5 seconds
    @AppStorage("blinkOpacity") private var blinkOpacity: Double = 0.5 // 50% transparency
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Blinks")
            button.action = #selector(toggleSettings)
            button.target = self
        }
        
        // Create menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(toggleSettings), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Blink Now", action: #selector(blinkNow), keyEquivalent: "b"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Start the blink timer
        startBlinkTimer()
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
        let settingsView = SettingsView(
            blinkInterval: $blinkInterval,
            blinkDuration: $blinkDuration,
            blinkOpacity: $blinkOpacity,
            launchAtLogin: $launchAtLogin,
            onLaunchAtLoginChanged: { [weak self] enabled in
                self?.setLaunchAtLogin(enabled)
            },
            onIntervalChanged: { [weak self] in
                self?.restartBlinkTimer()
            }
        )
        
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Blinks Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 400, height: 350))
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow = window
    }
    
    @objc func blinkNow() {
        showBlinkAnimation()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func startBlinkTimer() {
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkInterval, repeats: true) { [weak self] _ in
            self?.showBlinkAnimation()
        }
    }
    
    private func restartBlinkTimer() {
        startBlinkTimer()
    }
    
    private func showBlinkAnimation() {
        let blinkWindow = BlinkWindow(opacity: blinkOpacity, duration: blinkDuration)
        blinkWindow.show()
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
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
}
