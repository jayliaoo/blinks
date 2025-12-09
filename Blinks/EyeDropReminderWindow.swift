import SwiftUI
import AppKit

class EyeDropReminderWindow {
    private var window: NSWindow?
    private var onDone: (() -> Void)?
    private var onSnooze: (() -> Void)?
    
    init(onDone: @escaping () -> Void, onSnooze: @escaping () -> Void) {
        self.onDone = onDone
        self.onSnooze = onSnooze
    }
    
    func show() {
        let reminderView = EyeDropReminderView(
            onDone: { [weak self] in
                self?.close()
                self?.onDone?()
            },
            onSnooze: { [weak self] in
                self?.close()
                self?.onSnooze?()
            }
        )
        
        let hostingController = NSHostingController(rootView: reminderView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Eye Drop Reminder"
        window.styleMask = [.titled, .fullSizeContentView]
        window.level = .floating // Stay on top
        window.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
        window.isOpaque = false
        window.hasShadow = true
        window.setContentSize(NSSize(width: 450, height: 340))
        window.center()
        
        // Show the window
        window.makeKeyAndOrderFront(nil)
        
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
        
        self.window = window
    }
    
    private func close() {
        window?.close()
        window = nil
    }
}

struct EyeDropReminderView: View {
    let onDone: () -> Void
    let onSnooze: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.8),
                    Color(red: 0.1, green: 0.2, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                
                // Title
                Text("Time for Eye Drops!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Message
                Text("Don't forget to use your eye drops to keep your eyes healthy and comfortable.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 40)
                
                // Buttons
                HStack(spacing: 20) {
                    // Snooze button
                    Button(action: onSnooze) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16))
                            Text("Snooze")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 150, height: 44)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        NSCursor.pointingHand.set()
                    }
                    
                    // Done button
                    Button(action: onDone) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Done")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.5))
                        .frame(width: 150, height: 44)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        NSCursor.pointingHand.set()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding(.vertical, 10)
        }
        .frame(width: 450, height: 340)
    }
}

#Preview {
    EyeDropReminderView(
        onDone: { print("Done") },
        onSnooze: { print("Snooze") }
    )
}
