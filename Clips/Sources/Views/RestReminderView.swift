import SwiftUI

struct RestReminderView: View {
    @ObservedObject var store: RestReminderStore
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        if themeManager.currentTheme == .glassmorphism {
            glassBody
        } else {
            pixelBody
        }
    }
    
    // MARK: - Glass Body
    private var glassBody: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Work Timer")
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(glassStatusColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: glassStatusColor.opacity(0.5), radius: 4)
                    Text(store.statusText)
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(glassStatusColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Timer Display
                    glassTimerDisplay
                        .padding(.top, 12)
                    
                    // Settings
                    glassSettingsSection
                        .padding(.horizontal, 12)
                    
                    // Controls
                    glassControlsSection
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
            }
        }
    }
    
    private var glassTimerDisplay: some View {
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
    
    private var glassSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(GlassmorphismTheme.glassFontBold(size: 13))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            
            // Enable toggle
            glassSettingRow(title: "Enabled") {
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
            glassSettingRow(title: "Work Time") {
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
            glassSettingRow(title: "Rest Time") {
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
    
    private func glassSettingRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
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
    
    private var glassControlsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if store.isRunning {
                    glassButton(title: "Pause", icon: "pause.fill", color: GlassmorphismTheme.warning, action: { store.pauseTimer() })
                    glassButton(title: "Stop", icon: "stop.fill", color: GlassmorphismTheme.danger, action: { store.stopTimer() })
                } else if store.remainingSeconds > 0 {
                    glassButton(title: "Resume", icon: "play.fill", color: GlassmorphismTheme.primary, isPrimary: true, action: { store.resumeTimer() })
                    glassButton(title: "Reset", icon: "arrow.counterclockwise", color: GlassmorphismTheme.textSecondary, action: { store.stopTimer() })
                } else {
                    glassButton(title: "Start", icon: "play.fill", color: GlassmorphismTheme.primary, isPrimary: true, isDisabled: !store.isEnabled, action: { store.startTimer() })
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
    
    private func glassButton(title: String, icon: String, color: Color, isPrimary: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) -> some View {
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
    
    private var glassStatusColor: Color {
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
    
    // MARK: - Pixel Body
    private var pixelBody: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> WORK_TIMER")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                    .shadow(color: PixelTheme.primary.opacity(0.5), radius: 3)
                Spacer()
                
                // Status indicator
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: statusColor.opacity(0.6), radius: 3)
                    Text(store.statusText.uppercased())
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(statusColor)
                        .shadow(color: statusColor.opacity(0.4), radius: 2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider(color: PixelTheme.primary)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Timer Display
                    timerDisplaySection
                        .padding(.top, 8)
                    
                    PixelDivider()
                        .padding(.horizontal, 12)
                    
                    // Settings
                    settingsSection
                        .padding(.horizontal, 12)
                    
                    PixelDivider()
                        .padding(.horizontal, 12)
                    
                    // Controls
                    controlsSection
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
            }
        }
        .background(PixelTheme.background)
    }
    
    // MARK: - Timer Display
    
    private var timerDisplaySection: some View {
        VStack(spacing: 16) {
            // ASCII art timer frame
            VStack(spacing: 0) {
                Text("╔════════════════════════╗")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                    .shadow(color: (store.isRestTime ? PixelTheme.primary : PixelTheme.secondary).opacity(0.4), radius: 3)
                
                Text("║                        ║")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                
                HStack {
                    Text("║")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                    Spacer()
                    Text(store.formattedRemainingTime)
                        .font(PixelTheme.pixelFontBold(size: 36))
                        .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.accent)
                        .shadow(color: (store.isRestTime ? PixelTheme.primary : PixelTheme.accent).opacity(0.6), radius: 6)
                    Spacer()
                    Text("║")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                }
                .frame(width: 200)
                
                Text("║                        ║")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                
                Text("╚════════════════════════╝")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                    .shadow(color: (store.isRestTime ? PixelTheme.primary : PixelTheme.secondary).opacity(0.4), radius: 3)
            }
            
            // Mode label
            Text(store.isRestTime ? "[ REST MODE ]" : "[ WORK MODE ]")
                .font(PixelTheme.pixelFontBold(size: 14))
                .foregroundColor(store.isRestTime ? PixelTheme.primary : PixelTheme.secondary)
                .shadow(color: (store.isRestTime ? PixelTheme.primary : PixelTheme.secondary).opacity(0.5), radius: 4)
            
            // Progress bar
            VStack(spacing: 4) {
                PixelProgressBar(
                    progress: timerProgress,
                    foregroundColor: store.isRestTime ? PixelTheme.primary : PixelTheme.secondary,
                    height: 12
                )
                .frame(width: 200)
                
                Text("\(Int(timerProgress * 100))% COMPLETE")
                    .font(PixelTheme.pixelFont(size: 10))
                    .foregroundColor(PixelTheme.textSecondary)
            }
            
            // Status message
            if store.isEnabled && store.isRunning {
                HStack(spacing: 4) {
                    Text(">")
                        .foregroundColor(PixelTheme.primary)
                    Text(store.isRestTime ? "TAKE A BREAK..." : "FOCUS MODE ACTIVE")
                        .foregroundColor(PixelTheme.textPrimary)
                }
                .font(PixelTheme.pixelFont(size: 11))
            }
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
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("> SETTINGS")
                .font(PixelTheme.pixelFontBold(size: 12))
                .foregroundColor(PixelTheme.primary)
                .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
            
            // Enable toggle
            HStack {
                Text("ENABLED:")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.textPrimary)
                Spacer()
                Button(action: { store.isEnabled.toggle() }) {
                    Text(store.isEnabled ? "[ ON ]" : "[ OFF ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(store.isEnabled ? PixelTheme.primary : PixelTheme.danger)
                        .shadow(color: (store.isEnabled ? PixelTheme.primary : PixelTheme.danger).opacity(0.4), radius: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .background(PixelTheme.cardBackground)
            .pixelBorder(color: PixelTheme.borderHighlight)
            
            // Work duration
            HStack {
                Text("WORK_TIME:")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.textPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { decrementWork() }) {
                        Text("[-]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.secondary)
                            .shadow(color: PixelTheme.secondary.opacity(0.4), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                    
                    Text("\(store.workDurationMinutes) MIN")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.accent)
                        .shadow(color: PixelTheme.accent.opacity(0.4), radius: 2)
                        .frame(width: 70)
                    
                    Button(action: { incrementWork() }) {
                        Text("[+]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.secondary)
                            .shadow(color: PixelTheme.secondary.opacity(0.4), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                }
            }
            .padding(8)
            .background(PixelTheme.cardBackground)
            .pixelBorder(color: PixelTheme.borderHighlight)
            .opacity(store.isEnabled ? 1 : 0.5)
            
            // Rest duration
            HStack {
                Text("REST_TIME:")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.textPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { decrementRest() }) {
                        Text("[-]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.primary)
                            .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                    
                    Text("\(store.restDurationMinutes) MIN")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.primary)
                        .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
                        .frame(width: 70)
                    
                    Button(action: { incrementRest() }) {
                        Text("[+]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.primary)
                            .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.isEnabled)
                }
            }
            .padding(8)
            .background(PixelTheme.cardBackground)
            .pixelBorder(color: PixelTheme.borderHighlight)
            .opacity(store.isEnabled ? 1 : 0.5)
        }
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
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            Text("> CONTROLS")
                .font(PixelTheme.pixelFontBold(size: 12))
                .foregroundColor(PixelTheme.primary)
                .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                if store.isRunning {
                    // Pause button
                    Button(action: { store.pauseTimer() }) {
                        Text("[ PAUSE ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.warning)
                            .shadow(color: PixelTheme.warning.opacity(0.4), radius: 2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground, foregroundColor: PixelTheme.warning))
                    
                    // Stop button
                    Button(action: { store.stopTimer() }) {
                        Text("[ STOP ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.danger)
                            .shadow(color: PixelTheme.danger.opacity(0.4), radius: 2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground, foregroundColor: PixelTheme.danger))
                } else if store.remainingSeconds > 0 {
                    // Resume button
                    Button(action: { store.resumeTimer() }) {
                        Text("[ RESUME ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.primary, foregroundColor: PixelTheme.background))
                    
                    // Reset button
                    Button(action: { store.stopTimer() }) {
                        Text("[ RESET ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(PixelTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground, foregroundColor: PixelTheme.textPrimary))
                } else {
                    // Start button
                    Button(action: { store.startTimer() }) {
                        Text("[ START ]")
                            .font(PixelTheme.pixelFontBold(size: 12))
                            .foregroundColor(store.isEnabled ? PixelTheme.background : PixelTheme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(PixelButtonStyle(
                        backgroundColor: store.isEnabled ? PixelTheme.primary : PixelTheme.cardBackground,
                        foregroundColor: store.isEnabled ? PixelTheme.background : PixelTheme.textMuted
                    ))
                    .disabled(!store.isEnabled)
                }
            }
            
            // Skip rest button
            if store.isRestTime {
                Button(action: { store.skipRest() }) {
                    Text(">> SKIP REST")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var statusColor: Color {
        if !store.isEnabled {
            return PixelTheme.textMuted
        } else if !store.isRunning {
            return PixelTheme.warning
        } else if store.isRestTime {
            return PixelTheme.primary
        } else {
            return PixelTheme.secondary
        }
    }
}
