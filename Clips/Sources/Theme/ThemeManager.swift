import SwiftUI
import AppKit

// MARK: - Theme Colors (Glassmorphism only)
struct Theme {
    static var current: GlassmorphismThemeColors { GlassmorphismThemeColors() }
}

protocol ThemeColors {
    var background: Color { get }
    var cardBackground: Color { get }
    var headerBackground: Color { get }
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }
    var danger: Color { get }
    var warning: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textMuted: Color { get }
    var border: Color { get }
    var borderHighlight: Color { get }
    
    func font(size: CGFloat) -> Font
    func fontBold(size: CGFloat) -> Font
}

struct GlassmorphismThemeColors: ThemeColors {
    var background: Color { GlassmorphismTheme.background }
    var cardBackground: Color { GlassmorphismTheme.cardBackground }
    var headerBackground: Color { GlassmorphismTheme.headerBackground }
    var primary: Color { GlassmorphismTheme.primary }
    var secondary: Color { GlassmorphismTheme.secondary }
    var accent: Color { GlassmorphismTheme.accent }
    var danger: Color { GlassmorphismTheme.danger }
    var warning: Color { GlassmorphismTheme.warning }
    var textPrimary: Color { GlassmorphismTheme.textPrimary }
    var textSecondary: Color { GlassmorphismTheme.textSecondary }
    var textMuted: Color { GlassmorphismTheme.textMuted }
    var border: Color { GlassmorphismTheme.border }
    var borderHighlight: Color { GlassmorphismTheme.borderHighlight }

    func font(size: CGFloat) -> Font { GlassmorphismTheme.glassFont(size: size) }
    func fontBold(size: CGFloat) -> Font { GlassmorphismTheme.glassFontBold(size: size) }
}
