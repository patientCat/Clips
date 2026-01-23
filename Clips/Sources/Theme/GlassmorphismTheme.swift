import SwiftUI
import AppKit

// MARK: - Glassmorphism Theme (Modern Translucent Style)
struct GlassmorphismTheme {
    // Soft gradient backgrounds with transparency
    static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackground = Color.white.opacity(0.7)
    static let headerBackground = Color.white.opacity(0.5)

    // Modern soft accent colors
    static let primary = Color(red: 0.4, green: 0.6, blue: 1.0)       // Soft Blue
    static let secondary = Color(red: 0.5, green: 0.7, blue: 0.95)    // Light Sky Blue
    static let accent = Color(red: 0.8, green: 0.5, blue: 1.0)        // Soft Purple
    static let danger = Color(red: 1.0, green: 0.4, blue: 0.5)        // Soft Red
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.3)       // Soft Orange

    // Soft contrast text colors
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.2)  // Dark Gray
    static let textSecondary = Color(red: 0.35, green: 0.35, blue: 0.4) // Medium Gray
    static let textMuted = Color(red: 0.55, green: 0.55, blue: 0.6)    // Light Gray
    
    // Dark mode text colors
    static let textPrimaryDark = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let textSecondaryDark = Color(red: 0.75, green: 0.75, blue: 0.8)
    static let textMutedDark = Color(red: 0.55, green: 0.55, blue: 0.6)

    // Soft borders with transparency
    static let border = Color.white.opacity(0.3)
    static let borderHighlight = Color.white.opacity(0.6)
    
    // Inner stroke for glass edge effect (0.5pt)
    static let innerStroke = Color.white.opacity(0.5)
    static let innerStrokeDark = Color.white.opacity(0.2)

    // Glass shadow
    static let shadowColor = Color.black.opacity(0.08)

    // San Francisco font - modern macOS system font
    static func glassFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func glassFontBold(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
}

// MARK: - VisualEffectView (AppKit Wrapper for Desktop Wallpaper Bleed-through)
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State
    var isEmphasized: Bool
    
    init(
        material: NSVisualEffectView.Material = .sidebar,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .followsWindowActiveState,
        isEmphasized: Bool = true
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
        self.isEmphasized = isEmphasized
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.isEmphasized = isEmphasized
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
        nsView.isEmphasized = isEmphasized
    }
}

// MARK: - Glassmorphism View Modifier with ultraThinMaterial and 0.5pt Inner Stroke
struct GlassmorphismModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 16
    var strokeWidth: CGFloat = 0.5
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Ultra thin material for glass effect
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle white inner stroke (0.5pt) to mimic glass edge
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    colorScheme == .dark ? GlassmorphismTheme.innerStrokeDark : GlassmorphismTheme.innerStroke,
                                    colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                }
            )
            .shadow(color: GlassmorphismTheme.shadowColor, radius: 10, x: 0, y: 4)
    }
}

// MARK: - Glassmorphism Sidebar (Desktop Wallpaper Bleed-through)
struct GlassSidebar<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: Content
    var width: CGFloat = 220
    
    init(width: CGFloat = 220, @ViewBuilder content: () -> Content) {
        self.width = width
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // VisualEffectView allows desktop wallpaper to bleed through
            VisualEffectView(
                material: .sidebar,
                blendingMode: .behindWindow,
                state: .active,
                isEmphasized: true
            )
            
            // Additional glass overlay for enhanced effect
            Rectangle()
                .fill(
                    colorScheme == .dark
                        ? Color.black.opacity(0.2)
                        : Color.white.opacity(0.1)
                )
            
            // Content
            content
        }
        .frame(width: width)
        .overlay(
            // Right edge highlight
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            colorScheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .trailing,
                        endPoint: .leading
                    )
                )
                .frame(width: 1),
            alignment: .trailing
        )
    }
}

// MARK: - Glass Card with Dynamic Gradient Glow (Mouse Following)
struct GlassCardWithGlow<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var mousePosition: CGPoint = .zero
    @State private var isHovering: Bool = false
    
    let content: Content
    var cornerRadius: CGFloat = 20
    var glowColors: [Color] = [
        Color(red: 0.4, green: 0.6, blue: 1.0),   // Blue
        Color(red: 0.8, green: 0.5, blue: 1.0),   // Purple
        Color(red: 1.0, green: 0.5, blue: 0.7)    // Pink
    ]
    var glowRadius: CGFloat = 80
    var glowOpacity: Double = 0.6
    
    init(
        cornerRadius: CGFloat = 20,
        glowColors: [Color]? = nil,
        glowRadius: CGFloat = 80,
        glowOpacity: Double = 0.6,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        if let colors = glowColors {
            self.glowColors = colors
        }
        self.glowRadius = glowRadius
        self.glowOpacity = glowOpacity
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic gradient glow behind the card
                if isHovering {
                    RadialGradient(
                        colors: glowColors.map { $0.opacity(glowOpacity) } + [.clear],
                        center: UnitPoint(
                            x: mousePosition.x / geometry.size.width,
                            y: mousePosition.y / geometry.size.height
                        ),
                        startRadius: 0,
                        endRadius: glowRadius
                    )
                    .blur(radius: 30)
                    .animation(.easeOut(duration: 0.15), value: mousePosition)
                }
                
                // Glass card
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        colorScheme == .dark ? Color.white.opacity(0.2) : Color.white.opacity(0.6),
                                        colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: GlassmorphismTheme.shadowColor, radius: 20, x: 0, y: 10)
                
                // Content
                content
            }
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    mousePosition = location
                    isHovering = true
                case .ended:
                    isHovering = false
                }
            }
        }
    }
}

// MARK: - Mouse Tracking Glow Modifier
struct MouseTrackingGlow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State private var mousePosition: CGPoint = .zero
    @State private var isHovering: Bool = false
    
    var glowColors: [Color]
    var glowRadius: CGFloat
    var glowOpacity: Double
    var cornerRadius: CGFloat
    
    init(
        glowColors: [Color] = [GlassmorphismTheme.primary, GlassmorphismTheme.accent],
        glowRadius: CGFloat = 100,
        glowOpacity: Double = 0.5,
        cornerRadius: CGFloat = 16
    ) {
        self.glowColors = glowColors
        self.glowRadius = glowRadius
        self.glowOpacity = glowOpacity
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic glow layer
                if isHovering {
                    Canvas { context, size in
                        let center = mousePosition
                        let gradient = Gradient(colors: glowColors.map { $0.opacity(glowOpacity) } + [.clear])
                        
                        context.fill(
                            Path(ellipseIn: CGRect(
                                x: center.x - glowRadius,
                                y: center.y - glowRadius,
                                width: glowRadius * 2,
                                height: glowRadius * 2
                            )),
                            with: .radialGradient(
                                gradient,
                                center: center,
                                startRadius: 0,
                                endRadius: glowRadius
                            )
                        )
                    }
                    .blur(radius: 25)
                    .animation(.easeOut(duration: 0.1), value: mousePosition)
                }
                
                content
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    mousePosition = location
                    isHovering = true
                case .ended:
                    isHovering = false
                }
            }
        }
    }
}

// MARK: - Glass Material Modifier
struct GlassMaterial: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color = GlassmorphismTheme.cardBackground
    var cornerRadius: CGFloat = 16
    var borderColor: Color = GlassmorphismTheme.border

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Glass effect with blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: cornerRadius)
                        )

                    // Border highlight with inner stroke
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    colorScheme == .dark ? Color.white.opacity(0.2) : borderColor,
                                    colorScheme == .dark ? Color.white.opacity(0.05) : borderColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .shadow(color: GlassmorphismTheme.shadowColor, radius: 10, x: 0, y: 4)
            .shadow(color: GlassmorphismTheme.shadowColor, radius: 20, x: 0, y: 8)
    }
}

// MARK: - Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color = GlassmorphismTheme.primary.opacity(0.15)
    var foregroundColor: Color = GlassmorphismTheme.primary
    var isSmall: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GlassmorphismTheme.glassFont(size: isSmall ? 12 : 14))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, isSmall ? 12 : 16)
            .padding(.vertical, isSmall ? 6 : 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: isSmall ? 8 : 12)
                        .fill(configuration.isPressed ? backgroundColor.opacity(0.6) : backgroundColor)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: isSmall ? 8 : 12)
                        )

                    RoundedRectangle(cornerRadius: isSmall ? 8 : 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    foregroundColor.opacity(0.5),
                                    foregroundColor.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(color: foregroundColor.opacity(0.2), radius: configuration.isPressed ? 2 : 6, x: 0, y: configuration.isPressed ? 1 : 3)
    }
}

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color = GlassmorphismTheme.cardBackground
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: cornerRadius)
                        )

                    // 0.5pt inner stroke for glass edge
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    colorScheme == .dark ? Color.white.opacity(0.2) : GlassmorphismTheme.borderHighlight,
                                    colorScheme == .dark ? Color.white.opacity(0.05) : GlassmorphismTheme.border
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .shadow(color: GlassmorphismTheme.shadowColor, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Progress Bar
struct GlassProgressBar: View {
    var progress: CGFloat
    var foregroundColor: Color = GlassmorphismTheme.primary
    var backgroundColor: Color = GlassmorphismTheme.cardBackground
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(backgroundColor)
                    .background(
                        .ultraThinMaterial,
                        in: Capsule()
                    )
                    .overlay(
                        Capsule()
                            .stroke(GlassmorphismTheme.border, lineWidth: 1)
                    )

                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                foregroundColor,
                                foregroundColor.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
                    .shadow(color: foregroundColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Glass Tag
struct GlassTag: View {
    let text: String
    var color: Color = GlassmorphismTheme.accent
    var isSelected: Bool = false

    var body: some View {
        Text(text)
            .font(GlassmorphismTheme.glassFont(size: 11))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(color)
                    } else {
                        Capsule()
                            .fill(color.opacity(0.2))
                            .background(
                                .ultraThinMaterial,
                                in: Capsule()
                            )
                    }

                    if !isSelected {
                        Capsule()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: isSelected ? color.opacity(0.3) : .clear,
                radius: 4,
                x: 0,
                y: 2
            )
    }
}

// MARK: - Glass Divider
struct GlassDivider: View {
    var color: Color = GlassmorphismTheme.border

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        color,
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

// MARK: - Glass Icon
struct GlassIcon: View {
    let systemName: String
    var color: Color = GlassmorphismTheme.primary
    var size: CGFloat = 20
    var withBackground: Bool = false

    var body: some View {
        Group {
            if withBackground {
                Image(systemName: systemName)
                    .font(.system(size: size, weight: .medium))
                    .foregroundColor(color)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                            .background(
                                .ultraThinMaterial,
                                in: Circle()
                            )
                    )
            } else {
                Image(systemName: systemName)
                    .font(.system(size: size, weight: .medium))
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Apply glassmorphism effect with ultraThinMaterial and 0.5pt inner stroke
    func glassmorphism(cornerRadius: CGFloat = 16, strokeWidth: CGFloat = 0.5) -> some View {
        modifier(GlassmorphismModifier(cornerRadius: cornerRadius, strokeWidth: strokeWidth))
    }
    
    /// Apply mouse-tracking gradient glow effect
    func mouseTrackingGlow(
        glowColors: [Color] = [GlassmorphismTheme.primary, GlassmorphismTheme.accent],
        glowRadius: CGFloat = 100,
        glowOpacity: Double = 0.5,
        cornerRadius: CGFloat = 16
    ) -> some View {
        modifier(MouseTrackingGlow(
            glowColors: glowColors,
            glowRadius: glowRadius,
            glowOpacity: glowOpacity,
            cornerRadius: cornerRadius
        ))
    }
    
    func glassMaterial(
        backgroundColor: Color = GlassmorphismTheme.cardBackground,
        cornerRadius: CGFloat = 16,
        borderColor: Color = GlassmorphismTheme.border
    ) -> some View {
        modifier(GlassMaterial(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            borderColor: borderColor
        ))
    }

    func glassCard(
        backgroundColor: Color = GlassmorphismTheme.cardBackground,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16
    ) -> some View {
        modifier(GlassCard(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }

    func glassText() -> some View {
        self.font(GlassmorphismTheme.glassFont(size: 14))
            .foregroundColor(GlassmorphismTheme.textPrimary)
    }

    func glassHeadline() -> some View {
        self.font(GlassmorphismTheme.glassFontBold(size: 16))
            .foregroundColor(GlassmorphismTheme.textPrimary)
    }

    func glassCaption() -> some View {
        self.font(GlassmorphismTheme.glassFont(size: 12))
            .foregroundColor(GlassmorphismTheme.textSecondary)
    }
}

// MARK: - Glass Text Field Style
struct GlassTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(GlassmorphismTheme.glassFont(size: 14))
            .foregroundColor(colorScheme == .dark ? GlassmorphismTheme.textPrimaryDark : GlassmorphismTheme.textPrimary)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.5))
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 10)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        colorScheme == .dark ? Color.white.opacity(0.15) : GlassmorphismTheme.border,
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - Glass Gradient Background
struct GlassGradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.12, blue: 0.18),
                        Color(red: 0.15, green: 0.12, blue: 0.2),
                        Color(red: 0.12, green: 0.1, blue: 0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.90, blue: 0.98),
                        Color(red: 0.95, green: 0.92, blue: 0.98),
                        Color(red: 0.98, green: 0.95, blue: 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Animated Gradient Orbs Background
struct AnimatedGradientOrbs: View {
    @State private var animateOrbs = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background base
            GlassGradientBackground()
            
            // Animated gradient orbs for enhanced glass refraction feel
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GlassmorphismTheme.primary.opacity(0.3),
                            GlassmorphismTheme.primary.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: animateOrbs ? -100 : -150, y: animateOrbs ? -80 : -120)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GlassmorphismTheme.accent.opacity(0.25),
                            GlassmorphismTheme.accent.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .offset(x: animateOrbs ? 120 : 150, y: animateOrbs ? 100 : 80)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GlassmorphismTheme.secondary.opacity(0.2),
                            GlassmorphismTheme.secondary.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: animateOrbs ? -50 : 0, y: animateOrbs ? 150 : 120)
                .blur(radius: 40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateOrbs = true
            }
        }
    }
}

// MARK: - Floating Animation Modifier
struct FloatingAnimation: ViewModifier {
    @State private var isAnimating = false
    var delay: Double = 0

    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -8 : 0)
            .animation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func floatingAnimation(delay: Double = 0) -> some View {
        modifier(FloatingAnimation(delay: delay))
    }
}

// MARK: - Glass Tab Button
struct GlassTabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(GlassmorphismTheme.glassFont(size: 12))
            }
            .foregroundColor(isSelected ? .white : GlassmorphismTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        GlassmorphismTheme.primary,
                                        GlassmorphismTheme.primary.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                    }
                    
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            isSelected 
                                ? Color.white.opacity(0.3)
                                : Color.white.opacity(isHovering ? 0.3 : 0.15),
                            lineWidth: 0.5
                        )
                }
            )
            .shadow(
                color: isSelected ? GlassmorphismTheme.primary.opacity(0.4) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isHovering && !isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Glass Clipboard Row
struct GlassClipboardRow: View {
    let item: ClipboardItem
    let showFavoriteButton: Bool
    var onCopy: () -> Void
    var onToggleFavorite: (() -> Void)?
    
    @State private var isHovering = false
    @State private var showPreview = false
    @State private var hoverTimer: Timer?
    
    init(item: ClipboardItem, showFavoriteButton: Bool = false, onCopy: @escaping () -> Void, onToggleFavorite: (() -> Void)? = nil) {
        self.item = item
        self.showFavoriteButton = showFavoriteButton
        self.onCopy = onCopy
        self.onToggleFavorite = onToggleFavorite
    }
    
    var body: some View {
        Button(action: onCopy) {
            HStack(spacing: 10) {
                // Type indicator - pill style
                Text(item.contentType == .image ? "IMG" : "TXT")
                    .font(GlassmorphismTheme.glassFont(size: 10))
                    .foregroundColor(item.contentType == .image ? GlassmorphismTheme.secondary : GlassmorphismTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((item.contentType == .image ? GlassmorphismTheme.secondary : GlassmorphismTheme.primary).opacity(0.15))
                    )
                
                // Content
                if item.contentType == .image {
                    if let thumbnail = item.thumbnail(maxSize: 28) {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    Text(item.content)
                        .font(GlassmorphismTheme.glassFont(size: 13))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                        .lineLimit(2)
                } else {
                    Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(GlassmorphismTheme.glassFont(size: 13))
                        .foregroundColor(GlassmorphismTheme.textPrimary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    if showFavoriteButton {
                        Button(action: {
                            onToggleFavorite?()
                        }) {
                            Image(systemName: item.isFavorite ? "star.fill" : "star")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(item.isFavorite ? GlassmorphismTheme.warning : GlassmorphismTheme.textMuted)
                                .shadow(color: item.isFavorite ? GlassmorphismTheme.warning.opacity(0.5) : .clear, radius: 4)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                        }
                    }
                    
                    if isHovering {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(GlassmorphismTheme.primary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                    
                    if isHovering {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(GlassmorphismTheme.primary.opacity(0.08))
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isHovering ? 0.4 : 0.25),
                                    Color.white.opacity(isHovering ? 0.15 : 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            )
            .shadow(color: Color.black.opacity(isHovering ? 0.12 : 0.06), radius: isHovering ? 12 : 6, x: 0, y: isHovering ? 6 : 3)
            .scaleEffect(isHovering ? 1.01 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
            
            if item.contentType == .image {
                if hovering {
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                        showPreview = true
                    }
                } else {
                    hoverTimer?.invalidate()
                    hoverTimer = nil
                    showPreview = false
                }
            }
        }
        .popover(isPresented: $showPreview, arrowEdge: .trailing) {
            GlassImagePreview(item: item)
        }
    }
}

// MARK: - Glass Image Preview
struct GlassImagePreview: View {
    let item: ClipboardItem
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(GlassmorphismTheme.glassFontBold(size: 14))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            
            if let image = item.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            
            Text(item.content)
                .font(GlassmorphismTheme.glassFont(size: 12))
                .foregroundColor(GlassmorphismTheme.textSecondary)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
            }
        )
    }
}

// MARK: - Glass Empty State
struct GlassEmptyState: View {
    let icon: String
    let message: String
    var submessage: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Icon with glass background
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                    .frame(width: 72, height: 72)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(GlassmorphismTheme.textMuted)
            }
            
            VStack(spacing: 6) {
                Text(message)
                    .font(GlassmorphismTheme.glassFontBold(size: 15))
                    .foregroundColor(GlassmorphismTheme.textSecondary)
                
                if let submessage = submessage {
                    Text(submessage)
                        .font(GlassmorphismTheme.glassFont(size: 13))
                        .foregroundColor(GlassmorphismTheme.textMuted)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Glass Search Bar
struct GlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(GlassmorphismTheme.textMuted)
            
            TextField(placeholder, text: $text)
                .font(GlassmorphismTheme.glassFont(size: 14))
                .foregroundColor(GlassmorphismTheme.textPrimary)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(GlassmorphismTheme.textMuted)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Glass Section Header
struct GlassSectionHeader: View {
    let title: String
    var count: Int?
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(title)
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                
                if let count = count {
                    Text("\(count)")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(GlassmorphismTheme.primary.opacity(0.15))
                        )
                }
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.danger)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
