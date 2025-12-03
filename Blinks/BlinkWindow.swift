import SwiftUI
import AppKit

class BlinkWindow {
    private var window: NSWindow?
    private let opacity: Double
    private let duration: Double
    
    init(opacity: Double, duration: Double) {
        self.opacity = opacity
        self.duration = duration
    }
    
    func show() {
        // Get all screens to cover all displays
        let screens = NSScreen.screens
        
        for screen in screens {
            createBlinkWindow(for: screen)
        }
    }
    
    private func createBlinkWindow(for screen: NSScreen) {
        let blinkView = BlinkView(opacity: opacity)
        let hostingController = NSHostingController(rootView: blinkView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.borderless, .fullSizeContentView]
        window.level = .screenSaver // Above everything
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        
        // Set window to cover the entire screen
        window.setFrame(screen.frame, display: true)
        
        // Show the window
        window.orderFrontRegardless()
        
        // Animate and close after duration
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.15
                window.animator().alphaValue = 1.0
            }, completionHandler: {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.15
                        window.animator().alphaValue = 0.0
                    }, completionHandler: {
                        window.close()
                    })
                }
            })
        }
        
        self.window = window
    }
}

struct BlinkView: View {
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Black overlay
            Rectangle()
                .fill(Color.black.opacity(opacity))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // "Blink Your Eyes!" text
            Text("Blink Your Eyes!")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
