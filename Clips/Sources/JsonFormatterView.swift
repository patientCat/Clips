import SwiftUI
import AppKit

struct JsonFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var errorMessage: String? = nil
    @State private var indentSize: Int = 2
    @State private var isCompact: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var onCopy: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> JSON_FORMATTER")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Spacer()
                
                // Indent size selector
                HStack(spacing: 4) {
                    Text("INDENT:")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.textSecondary)
                    
                    ForEach([2, 4], id: \.self) { size in
                        Button(action: { indentSize = size }) {
                            Text("[\(size)]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(indentSize == size ? PixelTheme.primary : PixelTheme.textMuted)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Compact toggle
                Button(action: { isCompact.toggle(); formatJson() }) {
                    Text(isCompact ? "[COMPACT:ON]" : "[COMPACT:OFF]")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(isCompact ? PixelTheme.accent : PixelTheme.textMuted)
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
                    Spacer()
                    
                    Button(action: pasteFromClipboard) {
                        Text("[PASTE]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: clearInput) {
                        Text("[CLR]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.danger)
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
                .pixelBorder(color: PixelTheme.border, width: 2)
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
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if let error = errorMessage {
                    Text("⚠ \(error)")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.danger)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider()
            
            // Output area
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("> OUTPUT_JSON")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.primary)
                    
                    if !outputText.isEmpty {
                        Text("[\(outputText.count) CHARS]")
                            .font(PixelTheme.pixelFont(size: 10))
                            .foregroundColor(PixelTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    if !outputText.isEmpty {
                        Button(action: { onCopy(outputText) }) {
                            Text("[COPY]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.primary)
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
            errorMessage = "INVALID UTF-8"
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
            errorMessage = "PARSE ERROR: \(error.localizedDescription.uppercased())"
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
        .pixelBorder(color: PixelTheme.border, width: 2)
    }
}
