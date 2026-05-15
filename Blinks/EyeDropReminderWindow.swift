import SwiftUI
import AppKit

class EyeDropReminderWindow {
    private var window: NSWindow?
    private var onDone: (() -> Void)?
    private var onSnooze: (() -> Void)?
    private var onNotGood: (() -> Void)?
    private var onGood: (() -> Void)?

    init(onDone: @escaping () -> Void, onSnooze: @escaping () -> Void, onNotGood: @escaping () -> Void, onGood: @escaping () -> Void) {
        self.onDone = onDone
        self.onSnooze = onSnooze
        self.onNotGood = onNotGood
        self.onGood = onGood
    }
    
    func show() {
        let reminderView = EyeDropReminderView(
            onNotGood: { [weak self] in
                self?.close()
                self?.onNotGood?()
            },
            onGood: { [weak self] in
                self?.close()
                self?.onGood?()
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
    
    func close() {
        window?.close()
        window = nil
    }
}

struct EyeDropReminderView: View {
    let onNotGood: () -> Void
    let onGood: () -> Void
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

            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: "drop.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)

                // Title
                Text("Time for Eye Drops!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
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

                // Feeling buttons row
                HStack(spacing: 16) {
                    Button(action: onNotGood) {
                        HStack {
                            Image(systemName: "face.dashed")
                                .font(.system(size: 14))
                            Text("Not Feeling Good")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        if hovering { NSCursor.pointingHand.set() }
                    }

                    Button(action: onGood) {
                        HStack {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 14))
                            Text("Feeling Good")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        if hovering { NSCursor.pointingHand.set() }
                    }
                }
                .padding(.horizontal, 20)

                // Snooze button
                Button(action: onSnooze) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                        Text("Snooze")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.set() }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
        }
        .frame(width: 450, height: 320)
    }
}

#Preview {
    EyeDropReminderView(
        onNotGood: { print("Not Feeling Good") },
        onGood: { print("Feeling Good") },
        onSnooze: { print("Snooze") }
    )
}
