import SwiftUI
import AppKit

struct JsonFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var errorMessage: String? = nil
    @State private var indentSize: Int = 2
    @State private var isCompact: Bool = false
    @FocusState private var isInputFocused: Bool
    @ObservedObject var themeManager = ThemeManager.shared
    
    var onCopy: (String) -> Void
    
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
                Text("JSON Formatter")
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                Spacer()
                
                // Indent size selector
                HStack(spacing: 8) {
                    Text("Indent:")
                        .font(GlassmorphismTheme.glassFont(size: 11))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                    
                    ForEach([2, 4], id: \.self) { size in
                        Button(action: { indentSize = size; formatJson() }) {
                            Text("\(size)")
                                .font(GlassmorphismTheme.glassFont(size: 11))
                                .foregroundColor(indentSize == size ? .white : GlassmorphismTheme.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule().fill(indentSize == size ? GlassmorphismTheme.primary : Color.white.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Compact toggle
                Button(action: { isCompact.toggle(); formatJson() }) {
                    HStack(spacing: 4) {
                        Image(systemName: isCompact ? "arrow.right.arrow.left" : "text.alignleft")
                            .font(.system(size: 10, weight: .medium))
                        Text(isCompact ? "Compact" : "Pretty")
                            .font(GlassmorphismTheme.glassFont(size: 11))
                    }
                    .foregroundColor(isCompact ? .white : GlassmorphismTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(isCompact ? GlassmorphismTheme.accent : Color.white.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // Input area
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Input JSON")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                    Spacer()
                    
                    Button(action: pasteFromClipboard) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.system(size: 10))
                            Text("Paste")
                                .font(GlassmorphismTheme.glassFont(size: 11))
                        }
                        .foregroundColor(GlassmorphismTheme.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: clearInput) {
                        Text("Clear")
                            .font(GlassmorphismTheme.glassFont(size: 11))
                            .foregroundColor(GlassmorphismTheme.danger)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                
                GlassTextEditor(text: $inputText, placeholder: "Paste or type JSON here...", isEditable: true)
                    .frame(height: 120)
                    .padding(.horizontal, 10)
                    .focused($isInputFocused)
                    .onChange(of: inputText) { _ in formatJson() }
            }
            
            // Format button & error
            HStack {
                Button(action: formatJson) {
                    HStack(spacing: 6) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 12, weight: .medium))
                        Text("Format")
                            .font(GlassmorphismTheme.glassFontBold(size: 13))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(GlassmorphismTheme.primary)
                    )
                    .shadow(color: GlassmorphismTheme.primary.opacity(0.3), radius: 6)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if let error = errorMessage {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 11))
                        Text(error)
                            .font(GlassmorphismTheme.glassFont(size: 11))
                    }
                    .foregroundColor(GlassmorphismTheme.danger)
                    .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // Output area
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Output")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                    
                    if !outputText.isEmpty {
                        Text("\(outputText.count) chars")
                            .font(GlassmorphismTheme.glassFont(size: 10))
                            .foregroundColor(GlassmorphismTheme.textMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.white.opacity(0.1)))
                    }
                    
                    Spacer()
                    
                    if !outputText.isEmpty {
                        Button(action: { onCopy(outputText) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 10))
                                Text("Copy")
                                    .font(GlassmorphismTheme.glassFont(size: 11))
                            }
                            .foregroundColor(GlassmorphismTheme.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                
                GlassTextEditor(text: .constant(outputText), placeholder: "Formatted JSON will appear here...", isEditable: false)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
        }
        .onAppear { isInputFocused = true }
        .background(
            Button("", action: pasteFromClipboard)
                .keyboardShortcut("v", modifiers: .command)
                .hidden()
        )
    }
    
    // MARK: - Pixel Body
    private var pixelBody: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> JSON_FORMATTER")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                    .shadow(color: PixelTheme.primary.opacity(0.5), radius: 3)
                Spacer()
                
                // Indent size selector
                HStack(spacing: 4) {
                    Text("INDENT:")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.textPrimary)
                    
                    ForEach([2, 4], id: \.self) { size in
                        Button(action: { indentSize = size }) {
                            Text("[\(size)]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(indentSize == size ? PixelTheme.primary : PixelTheme.textSecondary)
                                .shadow(color: indentSize == size ? PixelTheme.primary.opacity(0.4) : .clear, radius: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Compact toggle
                Button(action: { isCompact.toggle(); formatJson() }) {
                    Text(isCompact ? "[COMPACT:ON]" : "[COMPACT:OFF]")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(isCompact ? PixelTheme.accent : PixelTheme.textSecondary)
                        .shadow(color: isCompact ? PixelTheme.accent.opacity(0.4) : .clear, radius: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider()
            
            // Input area
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("> INPUT_JSON")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.accent)
                        .shadow(color: PixelTheme.accent.opacity(0.4), radius: 2)
                    Spacer()
                    
                    Button(action: pasteFromClipboard) {
                        Text("[PASTE]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.secondary)
                            .shadow(color: PixelTheme.secondary.opacity(0.4), radius: 2)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: clearInput) {
                        Text("[CLR]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.danger)
                            .shadow(color: PixelTheme.danger.opacity(0.4), radius: 2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                ZStack(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text("PASTE OR TYPE JSON HERE...")
                            .font(PixelTheme.pixelFont(size: 11))
                            .foregroundColor(PixelTheme.textMuted)
                            .padding(8)
                    }
                    
                    TextEditor(text: $inputText)
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($isInputFocused)
                        .onChange(of: inputText) { _ in
                            formatJson()
                        }
                }
                .frame(height: 120)
                .background(PixelTheme.background)
                .pixelBorder(color: PixelTheme.borderHighlight, width: 2)
                .padding(.horizontal, 8)
                .onTapGesture {
                    isInputFocused = true
                }
            }
            
            // Format button
            HStack {
                Button(action: formatJson) {
                    HStack(spacing: 6) {
                        Text("▶")
                            .font(PixelTheme.pixelFont(size: 12))
                        Text("FORMAT")
                            .font(PixelTheme.pixelFontBold(size: 12))
                    }
                    .foregroundColor(PixelTheme.background)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(PixelTheme.primary)
                    .pixelBorder(color: PixelTheme.primary, width: 2)
                    .shadow(color: PixelTheme.primary.opacity(0.4), radius: 4)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if let error = errorMessage {
                    Text("⚠ \(error)")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.danger)
                        .shadow(color: PixelTheme.danger.opacity(0.4), radius: 2)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider(color: PixelTheme.borderHighlight)
            
            // Output area
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("> OUTPUT_JSON")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.primary)
                        .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
                    
                    if !outputText.isEmpty {
                        Text("[\(outputText.count) CHARS]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    if !outputText.isEmpty {
                        Button(action: { onCopy(outputText) }) {
                            Text("[COPY]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.primary)
                                .shadow(color: PixelTheme.primary.opacity(0.4), radius: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                PixelTextEditor(text: .constant(outputText), placeholder: "FORMATTED JSON WILL APPEAR HERE...", isEditable: false)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            isInputFocused = true
        }
        // Add invisible button for Command+V shortcut
        .background(
            Button("", action: pasteFromClipboard)
                .keyboardShortcut("v", modifiers: .command)
                .hidden()
        )
    }
    
    // MARK: - Actions
    
    private func formatJson() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            outputText = ""
            errorMessage = nil
            return
        }
        
        guard let data = inputText.data(using: .utf8) else {
            errorMessage = themeManager.currentTheme == .glassmorphism ? "Invalid UTF-8" : "INVALID UTF-8"
            outputText = ""
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            
            if isCompact {
                let compactData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.sortedKeys])
                outputText = String(data: compactData, encoding: .utf8) ?? ""
            } else {
                let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
                var formatted = String(data: prettyData, encoding: .utf8) ?? ""
                
                // Adjust indentation if needed
                if indentSize == 4 {
                    formatted = adjustIndentation(formatted, spaces: 4)
                }
                
                outputText = formatted
            }
            errorMessage = nil
        } catch let error as NSError {
            let desc = error.localizedDescription
            errorMessage = themeManager.currentTheme == .glassmorphism ? desc : desc.uppercased()
            outputText = ""
        }
    }
    
    private func adjustIndentation(_ json: String, spaces: Int) -> String {
        let lines = json.components(separatedBy: "\n")
        var result: [String] = []
        
        for line in lines {
            var leadingSpaces = 0
            for char in line {
                if char == " " {
                    leadingSpaces += 1
                } else {
                    break
                }
            }
            
            // Default prettyPrinted uses 4 spaces, we need to adjust
            let indentLevel = leadingSpaces / 4
            let newIndent = String(repeating: " ", count: indentLevel * spaces)
            let trimmedLine = String(line.dropFirst(leadingSpaces))
            result.append(newIndent + trimmedLine)
        }
        
        return result.joined(separator: "\n")
    }
    
    private func pasteFromClipboard() {
        if let string = NSPasteboard.general.string(forType: .string) {
            inputText = string
            formatJson()
        }
    }
    
    private func clearInput() {
        inputText = ""
        outputText = ""
        errorMessage = nil
    }
}

// MARK: - Glass Text Editor
struct GlassTextEditor: View {
    @Binding var text: String
    var placeholder: String = ""
    var isEditable: Bool = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textMuted)
                    .padding(10)
            }
            
            if isEditable {
                TextEditor(text: $text)
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            } else {
                ScrollView {
                    Text(text)
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.textPrimary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Pixel Text Editor
struct PixelTextEditor: View {
    @Binding var text: String
    var placeholder: String = ""
    var isEditable: Bool = true
    var onPaste: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textMuted)
                    .padding(8)
            }
            
            if isEditable {
                TextEditor(text: $text)
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification)) { _ in
                        // This ensures the view stays responsive
                    }
            } else {
                ScrollView {
                    Text(text)
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
        }
        .background(PixelTheme.background)
        .pixelBorder(color: PixelTheme.borderHighlight, width: 2)
    }
}
