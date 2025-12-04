import SwiftUI

struct SettingsView: View {
    @ObservedObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Blinks Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                // Blink Interval
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Blink Interval:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(formatInterval(appDelegate.blinkInterval))
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    Slider(value: $appDelegate.blinkInterval, in: 30...300, step: 30) {
                        Text("Interval")
                    }
                    .onChange(of: appDelegate.blinkInterval) { _ in
                        appDelegate.restartBlinkTimer()
                    }
                    
                    HStack {
                        Text("0.5 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("5 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Blink Duration
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Blink Duration:")
                            .fontWeight(.medium)
                        Spacer()
                        Text(String(format: "%.1f sec", appDelegate.blinkDuration))
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    Slider(value: $appDelegate.blinkDuration, in: 0.5...5.0, step: 0.5) {
                        Text("Duration")
                    }
                    
                    HStack {
                        Text("0.5 sec")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("5.0 sec")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Opacity
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Opacity:")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(appDelegate.blinkOpacity * 100))%")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    Slider(value: $appDelegate.blinkOpacity, in: 0.1...1.0, step: 0.05) {
                        Text("Opacity")
                    }
                    
                    HStack {
                        Text("10%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("100%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Eye Drop Reminder Section
                VStack(alignment: .leading, spacing: 12) {
                    // Enable/Disable Toggle
                    Toggle(isOn: Binding(
                        get: { appDelegate.eyeDropEnabled },
                        set: { newValue in
                            appDelegate.eyeDropEnabled = newValue
                            if newValue && !appDelegate.isPaused {
                                appDelegate.restartEyeDropTimer()
                            }
                        }
                    )) {
                        Text("Eye Drop Reminder")
                            .fontWeight(.medium)
                    }
                    .toggleStyle(.switch)
                    
                    // Interval Slider (only shown when enabled)
                    if appDelegate.eyeDropEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Reminder Interval:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatInterval(appDelegate.eyeDropInterval))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                            }
                            
                            Slider(value: $appDelegate.eyeDropInterval, in: 300...7200, step: 300) {
                                Text("Eye Drop Interval")
                            }
                            .onChange(of: appDelegate.eyeDropInterval) { _ in
                                appDelegate.restartEyeDropTimer()
                            }
                            
                            HStack {
                                Text("5 min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("120 min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading, 20)
                        
                        // Snooze Duration Slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Snooze Duration:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatInterval(appDelegate.eyeDropSnoozeDuration))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                            }
                            
                            // Snooze duration must be less than interval
                            let maxSnooze = min(appDelegate.eyeDropInterval, 1800) // Max 30 min or interval
                            Slider(value: $appDelegate.eyeDropSnoozeDuration, in: 60...maxSnooze, step: 60) {
                                Text("Snooze Duration")
                            }
                            
                            HStack {
                                Text("1 min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatInterval(maxSnooze))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading, 20)
                    }
                }
                
                Divider()
                
                // Launch at Login
                Toggle(isOn: Binding(
                    get: { appDelegate.launchAtLogin },
                    set: { newValue in
                        appDelegate.launchAtLogin = newValue
                        appDelegate.setLaunchAtLogin(newValue)
                    }
                )) {
                    Text("Launch at Login")
                        .fontWeight(.medium)
                }
                .toggleStyle(.switch)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("The app will blink your screen at the specified interval to remind you to rest your eyes.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .frame(width: 400, height: 630)
    }
    
    private func formatInterval(_ seconds: Double) -> String {
        let minutes = seconds / 60.0
        
        if minutes < 60 {
            // Show one decimal place for minutes
            if minutes.truncatingRemainder(dividingBy: 1) == 0 {
                // Whole number, no decimal
                return String(format: "%.0f min", minutes)
            } else {
                // Has decimal, show it
                return String(format: "%.1f min", minutes)
            }
        } else {
            let hours = Int(minutes / 60)
            let remainingMinutes = Int(minutes.truncatingRemainder(dividingBy: 60))
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }
}


#Preview {
    let appDelegate = AppDelegate()
    return SettingsView(appDelegate: appDelegate)
}
