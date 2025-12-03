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
        .frame(width: 400, height: 350)
    }
    
    private func formatInterval(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
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
