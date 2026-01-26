import SwiftUI

struct RestReminderView: View {
    @ObservedObject var store: RestReminderStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Work Timer")
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: statusColor.opacity(0.5), radius: 4)
                    Text(store.statusText)
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(statusColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Timer Display
                    timerDisplay
                        .padding(.top, 12)
                    
                    // Settings
                    settingsSection
                        .padding(.horizontal, 12)
                    
                    // Controls
                    controlsSection
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
            }
        }
    }
    
    private var timerDisplay: some View {
        VStack(spacing: 16) {
            // Timer circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 160, height: 160)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                store.isRestTime ? GlassmorphismTheme.primary : GlassmorphismTheme.secondary,
                                store.isRestTime ? GlassmorphismTheme.accent : GlassmorphismTheme.primary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: timerProgress)
                
                // Glass inner circle
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                
                // Time display
                VStack(spacing: 4) {
                    Text(store.formattedRemainingTime)
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundColor(GlassmorphismTheme.textPrimary)
                    
                    Text(store.isRestTime ? "Rest" : "Focus")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(store.isRestTime ? GlassmorphismTheme.primary : GlassmorphismTheme.secondary)
                }
            }
            .shadow(color: (store.isRestTime ? GlassmorphismTheme.primary : GlassmorphismTheme.secondary).opacity(0.2), radius: 20)
            
            // Status message
            if store.isEnabled && store.isRunning {
                Text(store.isRestTime ? "Take a break..." : "Stay focused!")
                    .font(GlassmorphismTheme.glassFont(size: 13))
                    .foregroundColor(GlassmorphismTheme.textSecondary)
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(GlassmorphismTheme.glassFontBold(size: 13))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            
            // Enable toggle
            settingRow(title: "Enabled") {
                Button(action: { store.isEnabled.toggle() }) {
                    Text(store.isEnabled ? "On" : "Off")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(store.isEnabled ? .white : GlassmorphismTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(store.isEnabled ? GlassmorphismTheme.primary : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Work duration
            settingRow(title: "Work Time") {
                HStack(spacing: 8) {
                    Button(action: { decrementWork() }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GlassmorphismTheme.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                    
                    Text("\(store.workDurationMinutes) min")
                        .font(GlassmorphismTheme.glassFontBold(size: 14))
                        .foregroundColor(GlassmorphismTheme.secondary)
                        .frame(width: 60)
                    
                    Button(action: { incrementWork() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GlassmorphismTheme.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                }
            }
            .opacity(store.isEnabled ? 1 : 0.5)
            
            // Rest duration
            settingRow(title: "Rest Time") {
                HStack(spacing: 8) {
                    Button(action: { decrementRest() }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GlassmorphismTheme.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                    
                    Text("\(store.restDurationMinutes) min")
                        .font(GlassmorphismTheme.glassFontBold(size: 14))
                        .foregroundColor(GlassmorphismTheme.primary)
                        .frame(width: 60)
                    
                    Button(action: { incrementRest() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GlassmorphismTheme.textSecondary)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                }
            }
            .opacity(store.isEnabled ? 1 : 0.5)
        }
    }
    
    private func settingRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(GlassmorphismTheme.glassFont(size: 13))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            Spacer()
            content()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
        )
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if store.isRunning {
                    controlButton(title: "Pause", icon: "pause.fill", color: GlassmorphismTheme.warning, action: { store.pauseTimer() })
                    controlButton(title: "Stop", icon: "stop.fill", color: GlassmorphismTheme.danger, action: { store.stopTimer() })
                } else if store.remainingSeconds > 0 {
                    controlButton(title: "Resume", icon: "play.fill", color: GlassmorphismTheme.primary, isPrimary: true, action: { store.resumeTimer() })
                    controlButton(title: "Reset", icon: "arrow.counterclockwise", color: GlassmorphismTheme.textSecondary, action: { store.stopTimer() })
                } else {
                    controlButton(title: "Start", icon: "play.fill", color: GlassmorphismTheme.primary, isPrimary: true, isDisabled: !store.isEnabled, action: { store.startTimer() })
                }
            }
            
            if store.isRestTime {
                Button(action: { store.skipRest() }) {
                    Text("Skip Rest")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func controlButton(title: String, icon: String, color: Color, isPrimary: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(GlassmorphismTheme.glassFontBold(size: 13))
            }
            .foregroundColor(isPrimary ? .white : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isPrimary {
                        RoundedRectangle(cornerRadius: 10).fill(color)
                    } else {
                        RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isPrimary ? Color.clear : color.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: isPrimary ? color.opacity(0.3) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
    
    private var statusColor: Color {
        if !store.isEnabled {
            return GlassmorphismTheme.textMuted
        } else if !store.isRunning {
            return GlassmorphismTheme.warning
        } else if store.isRestTime {
            return GlassmorphismTheme.primary
        } else {
            return GlassmorphismTheme.secondary
        }
    }
    
    private var timerProgress: CGFloat {
        guard store.isRunning else { return 0 }
        
        let totalSeconds: Double
        if store.isRestTime {
            totalSeconds = Double(store.restDurationMinutes * 60)
        } else {
            totalSeconds = Double(store.workDurationMinutes * 60)
        }
        
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (CGFloat(store.remainingSeconds) / CGFloat(totalSeconds))
    }
    
    private let workOptions = [1, 5, 15, 20, 25, 30, 45, 60, 90]
    private let restOptions = [1, 3, 5, 10, 15, 20]
    
    private func incrementWork() {
        if let idx = workOptions.firstIndex(of: store.workDurationMinutes), idx < workOptions.count - 1 {
            store.workDurationMinutes = workOptions[idx + 1]
        }
    }
    
    private func decrementWork() {
        if let idx = workOptions.firstIndex(of: store.workDurationMinutes), idx > 0 {
            store.workDurationMinutes = workOptions[idx - 1]
        }
    }
    
    private func incrementRest() {
        if let idx = restOptions.firstIndex(of: store.restDurationMinutes), idx < restOptions.count - 1 {
            store.restDurationMinutes = restOptions[idx + 1]
        }
    }
    
    private func decrementRest() {
        if let idx = restOptions.firstIndex(of: store.restDurationMinutes), idx > 0 {
            store.restDurationMinutes = restOptions[idx - 1]
        }
    }
}
