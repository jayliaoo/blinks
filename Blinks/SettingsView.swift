import SwiftUI

struct SettingsView: View {
    @Binding var blinkInterval: Double
    @Binding var blinkDuration: Double
    @Binding var blinkOpacity: Double
    @Binding var launchAtLogin: Bool
    
    let onLaunchAtLoginChanged: (Bool) -> Void
    let onIntervalChanged: () -> Void
    
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
                        Text(formatInterval(blinkInterval))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $blinkInterval, in: 60...3600, step: 60) {
                        Text("Interval")
                    }
                    .onChange(of: blinkInterval) { _ in
                        onIntervalChanged()
                    }
                    
                    HStack {
                        Text("1 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("60 min")
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
                        Text(String(format: "%.1f sec", blinkDuration))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $blinkDuration, in: 0.1...3.0, step: 0.1) {
                        Text("Duration")
                    }
                    
                    HStack {
                        Text("0.1 sec")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("3.0 sec")
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
                        Text("\(Int(blinkOpacity * 100))%")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $blinkOpacity, in: 0.1...1.0, step: 0.05) {
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
                    get: { launchAtLogin },
                    set: { newValue in
                        launchAtLogin = newValue
                        onLaunchAtLoginChanged(newValue)
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
    SettingsView(
        blinkInterval: .constant(1200),
        blinkDuration: .constant(0.5),
        blinkOpacity: .constant(0.5),
        launchAtLogin: .constant(false),
        onLaunchAtLoginChanged: { _ in },
        onIntervalChanged: { }
    )
}
