import SwiftUI

struct KeyValueView: View {
    @ObservedObject var kvStore: KeyValueStore
    @ObservedObject var themeManager = ThemeManager.shared
    var onCopyValue: (String) -> Void
    
    @State private var searchText: String = ""
    @State private var selectedTag: String? = nil
    @State private var showAddSheet: Bool = false
    @State private var editingItem: KeyValueItem? = nil
    
    var filteredItems: [KeyValueItem] {
        kvStore.search(searchText, filterTag: selectedTag)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            if themeManager.currentTheme == .glassmorphism {
                GlassSectionHeader(
                    title: "Key Vault",
                    count: kvStore.items.count
                )
                .overlay(alignment: .trailing) {
                    HStack(spacing: 8) {
                        Button(action: { showAddSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .medium))
                                Text("Add")
                                    .font(GlassmorphismTheme.glassFont(size: 12))
                            }
                            .foregroundColor(GlassmorphismTheme.primary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: { kvStore.clear() }) {
                            Text("Clear")
                                .font(GlassmorphismTheme.glassFont(size: 12))
                                .foregroundColor(GlassmorphismTheme.danger)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.trailing, 12)
                }
            } else {
                HStack {
                    Text("> KEY_VAULT")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.primary)
                    Text("[\(kvStore.items.count)]")
                        .font(PixelTheme.pixelFont(size: 12))
                        .foregroundColor(PixelTheme.accent)
                    Spacer()
                    Button(action: { showAddSheet = true }) {
                        Text("[+ADD]")
                            .font(PixelTheme.pixelFont(size: 11))
                            .foregroundColor(PixelTheme.primary)
                    }
                    .buttonStyle(.plain)
                    Button(action: { kvStore.clear() }) {
                        Text("[CLR]")
                            .font(PixelTheme.pixelFont(size: 11))
                            .foregroundColor(PixelTheme.danger)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            // Tag filter bar
            if !kvStore.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        if themeManager.currentTheme == .glassmorphism {
                            GlassTagButton(tag: "All", isSelected: selectedTag == nil, action: { selectedTag = nil })
                            ForEach(kvStore.allTags, id: \.self) { tag in
                                GlassTagButton(tag: tag.capitalized, isSelected: selectedTag == tag, action: { selectedTag = selectedTag == tag ? nil : tag })
                            }
                        } else {
                            PixelTagButton(tag: "ALL", isSelected: selectedTag == nil, action: { selectedTag = nil })
                            ForEach(kvStore.allTags, id: \.self) { tag in
                                PixelTagButton(tag: tag.uppercased(), isSelected: selectedTag == tag, action: { selectedTag = selectedTag == tag ? nil : tag })
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(themeManager.currentTheme == .glassmorphism ? AnyView(Color.clear) : AnyView(PixelTheme.headerBackground))
            }
            
            // Search bar
            if themeManager.currentTheme == .glassmorphism {
                GlassSearchBar(text: $searchText, placeholder: "Search keys...")
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
            } else {
                HStack(spacing: 8) {
                    Text(">")
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.primary)
                    TextField("SEARCH KEYS...", text: $searchText)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Text("[X]")
                                .font(PixelTheme.pixelFont(size: 11))
                                .foregroundColor(PixelTheme.danger)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(PixelTheme.cardBackground)
                .pixelBorder()
                .padding(.horizontal, 8)
                
                PixelDivider()
                    .padding(.vertical, 4)
            }
            
            if filteredItems.isEmpty {
                if themeManager.currentTheme == .glassmorphism {
                    GlassEmptyState(
                        icon: searchText.isEmpty && selectedTag == nil ? "key" : "magnifyingglass",
                        message: searchText.isEmpty && selectedTag == nil ? "Vault Empty" : "No Results",
                        submessage: searchText.isEmpty && selectedTag == nil ? "Add your first key" : "Try a different search"
                    )
                } else {
                    VStack(spacing: 8) {
                        Spacer()
                        Text("╔══════════════════╗")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.border)
                        if searchText.isEmpty && selectedTag == nil {
                            Text("║   VAULT EMPTY    ║")
                                .font(PixelTheme.pixelFont(size: 12))
                                .foregroundColor(PixelTheme.textSecondary)
                            Text("║  [+] TO ADD KEY  ║")
                                .font(PixelTheme.pixelFont(size: 12))
                                .foregroundColor(PixelTheme.textMuted)
                        } else {
                            Text("║  NO MATCH FOUND  ║")
                                .font(PixelTheme.pixelFont(size: 12))
                                .foregroundColor(PixelTheme.textSecondary)
                        }
                        Text("╚══════════════════╝")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.border)
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: themeManager.currentTheme == .glassmorphism ? 8 : 4) {
                        ForEach(filteredItems) { item in
                            if themeManager.currentTheme == .glassmorphism {
                                GlassKeyValueRow(
                                    item: item,
                                    onCopy: { onCopyValue(item.value) },
                                    onEdit: { editingItem = item },
                                    onDelete: { kvStore.remove(id: item.id) }
                                )
                            } else {
                                PixelKeyValueRow(
                                    item: item,
                                    onCopy: { onCopyValue(item.value) },
                                    onEdit: { editingItem = item },
                                    onDelete: { kvStore.remove(id: item.id) }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, themeManager.currentTheme == .glassmorphism ? 10 : 8)
                    .padding(.vertical, themeManager.currentTheme == .glassmorphism ? 8 : 4)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            if themeManager.currentTheme == .glassmorphism {
                GlassAddKeyValueSheet(kvStore: kvStore, isPresented: $showAddSheet)
            } else {
                PixelAddKeyValueSheet(kvStore: kvStore, isPresented: $showAddSheet)
            }
        }
        .sheet(item: $editingItem) { item in
            if themeManager.currentTheme == .glassmorphism {
                GlassEditKeyValueSheet(kvStore: kvStore, item: item, isPresented: Binding(
                    get: { editingItem != nil },
                    set: { if !$0 { editingItem = nil } }
                ))
            } else {
                PixelEditKeyValueSheet(kvStore: kvStore, item: item, isPresented: Binding(
                    get: { editingItem != nil },
                    set: { if !$0 { editingItem = nil } }
                ))
            }
        }
    }
}

// MARK: - Glass Tag Button
struct GlassTagButton: View {
    let tag: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(GlassmorphismTheme.glassFont(size: 12))
                .foregroundColor(isSelected ? .white : GlassmorphismTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? GlassmorphismTheme.accent : Color.white.opacity(0.1))
                        .background(isSelected ? AnyView(Color.clear) : AnyView(Capsule().fill(.ultraThinMaterial)))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: isSelected ? GlassmorphismTheme.accent.opacity(0.3) : .clear, radius: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glass Key Value Row
struct GlassKeyValueRow: View {
    let item: KeyValueItem
    var onCopy: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isHovering = false
    @State private var showValue = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.key)
                    .font(GlassmorphismTheme.glassFontBold(size: 14))
                    .foregroundColor(GlassmorphismTheme.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if isHovering {
                    HStack(spacing: 12) {
                        Button(action: onCopy) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(GlassmorphismTheme.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(GlassmorphismTheme.warning)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(GlassmorphismTheme.danger)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            if !item.description.isEmpty {
                Text(item.description)
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textSecondary)
                    .lineLimit(1)
            }
            
            HStack(spacing: 8) {
                if showValue {
                    Text(item.value)
                        .font(GlassmorphismTheme.glassFont(size: 13))
                        .foregroundColor(GlassmorphismTheme.textPrimary)
                        .lineLimit(1)
                } else {
                    Text(String(repeating: "•", count: min(item.value.count, 16)))
                        .font(GlassmorphismTheme.glassFont(size: 13))
                        .foregroundColor(GlassmorphismTheme.textMuted)
                }
                
                Button(action: { showValue.toggle() }) {
                    Image(systemName: showValue ? "eye.slash" : "eye")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            
            if !item.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(GlassmorphismTheme.glassFont(size: 10))
                            .foregroundColor(GlassmorphismTheme.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(GlassmorphismTheme.secondary.opacity(0.15)))
                    }
                }
            }
        }
        .padding(12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                if isHovering {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(GlassmorphismTheme.primary.opacity(0.05))
                }
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.white.opacity(isHovering ? 0.3 : 0.15), lineWidth: 0.5)
            }
        )
        .shadow(color: Color.black.opacity(isHovering ? 0.1 : 0.05), radius: isHovering ? 10 : 5, x: 0, y: isHovering ? 4 : 2)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Glass Add Sheet
struct GlassAddKeyValueSheet: View {
    @ObservedObject var kvStore: KeyValueStore
    @Binding var isPresented: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var tagsText: String = ""
    
    var tags: [String] {
        tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Key")
                .font(GlassmorphismTheme.glassFontBold(size: 18))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            
            VStack(alignment: .leading, spacing: 16) {
                GlassTextField(title: "Key", placeholder: "Enter key name", text: $key, isRequired: true)
                GlassSecureField(title: "Value", placeholder: "Enter secret value", text: $value, isRequired: true)
                GlassTextField(title: "Description", placeholder: "Optional description", text: $description)
                GlassTextField(title: "Tags", placeholder: "tag1, tag2, tag3", text: $tagsText)
                
                if !kvStore.allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            Text("Existing:")
                                .font(GlassmorphismTheme.glassFont(size: 11))
                                .foregroundColor(GlassmorphismTheme.textMuted)
                            ForEach(kvStore.allTags, id: \.self) { tag in
                                Button(action: {
                                    if !tags.contains(tag) {
                                        tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                    }
                                }) {
                                    Text(tag)
                                        .font(GlassmorphismTheme.glassFont(size: 11))
                                        .foregroundColor(GlassmorphismTheme.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(GlassmorphismTheme.secondary.opacity(0.15)))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(GlassmorphismTheme.glassFont(size: 14))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.add(key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .font(GlassmorphismTheme.glassFontBold(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(key.isEmpty || value.isEmpty ? GlassmorphismTheme.textMuted : GlassmorphismTheme.primary))
                        .shadow(color: key.isEmpty || value.isEmpty ? .clear : GlassmorphismTheme.primary.opacity(0.3), radius: 6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(
            ZStack {
                GlassGradientBackground()
                RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
            }
        )
    }
}

// MARK: - Glass Edit Sheet
struct GlassEditKeyValueSheet: View {
    @ObservedObject var kvStore: KeyValueStore
    let item: KeyValueItem
    @Binding var isPresented: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var tagsText: String = ""
    
    var tags: [String] {
        tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Key")
                .font(GlassmorphismTheme.glassFontBold(size: 18))
                .foregroundColor(GlassmorphismTheme.warning)
            
            VStack(alignment: .leading, spacing: 16) {
                GlassTextField(title: "Key", placeholder: "Key", text: $key, isRequired: true)
                GlassSecureField(title: "Value", placeholder: "Value", text: $value, isRequired: true)
                GlassTextField(title: "Description", placeholder: "Description", text: $description)
                GlassTextField(title: "Tags", placeholder: "tag1, tag2", text: $tagsText)
            }
            
            HStack {
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(GlassmorphismTheme.glassFont(size: 14))
                        .foregroundColor(GlassmorphismTheme.textSecondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.update(id: item.id, key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }) {
                    Text("Update")
                        .font(GlassmorphismTheme.glassFontBold(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(key.isEmpty || value.isEmpty ? GlassmorphismTheme.textMuted : GlassmorphismTheme.warning))
                        .shadow(color: key.isEmpty || value.isEmpty ? .clear : GlassmorphismTheme.warning.opacity(0.3), radius: 6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(
            ZStack {
                GlassGradientBackground()
                RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
            }
        )
        .onAppear {
            key = item.key
            value = item.value
            description = item.description
            tagsText = item.tags.joined(separator: ", ")
        }
    }
}

// MARK: - Glass Text Field
struct GlassTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textSecondary)
                if isRequired {
                    Text("*")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.danger)
                }
            }
            TextField(placeholder, text: $text)
                .font(GlassmorphismTheme.glassFont(size: 14))
                .foregroundColor(GlassmorphismTheme.textPrimary)
                .textFieldStyle(.plain)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
        }
    }
}

// MARK: - Glass Secure Field
struct GlassSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(GlassmorphismTheme.glassFont(size: 12))
                    .foregroundColor(GlassmorphismTheme.textSecondary)
                if isRequired {
                    Text("*")
                        .font(GlassmorphismTheme.glassFont(size: 12))
                        .foregroundColor(GlassmorphismTheme.danger)
                }
            }
            SecureField(placeholder, text: $text)
                .font(GlassmorphismTheme.glassFont(size: 14))
                .foregroundColor(GlassmorphismTheme.textPrimary)
                .textFieldStyle(.plain)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
        }
    }
}

// MARK: - Pixel Tag Button
struct PixelTagButton: View {
    let tag: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(PixelTheme.pixelFont(size: 10))
                .foregroundColor(isSelected ? PixelTheme.background : PixelTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Rectangle()
                        .fill(isSelected ? PixelTheme.accent : PixelTheme.accent.opacity(0.25))
                )
                .overlay(
                    Rectangle()
                        .stroke(PixelTheme.accent, lineWidth: 1)
                )
                .shadow(color: isSelected ? PixelTheme.accent.opacity(0.4) : .clear, radius: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pixel Key Value Row
struct PixelKeyValueRow: View {
    let item: KeyValueItem
    var onCopy: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var isHovering = false
    @State private var showValue = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Key
                Text(item.key)
                    .font(PixelTheme.pixelFontBold(size: 13))
                    .foregroundColor(PixelTheme.accent)
                    .shadow(color: PixelTheme.accent.opacity(0.4), radius: 2)
                    .lineLimit(1)
                
                Spacer()
                
                if isHovering {
                    HStack(spacing: 8) {
                        Button(action: onCopy) {
                            Text("[CPY]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.secondary)
                                .shadow(color: PixelTheme.secondary.opacity(0.4), radius: 2)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onEdit) {
                            Text("[EDT]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.warning)
                                .shadow(color: PixelTheme.warning.opacity(0.4), radius: 2)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onDelete) {
                            Text("[DEL]")
                                .font(PixelTheme.pixelFont(size: 10))
                                .foregroundColor(PixelTheme.danger)
                                .shadow(color: PixelTheme.danger.opacity(0.4), radius: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Description
            if !item.description.isEmpty {
                Text("> \(item.description)")
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textSecondary)
                    .lineLimit(1)
            }
            
            // Value
            HStack(spacing: 8) {
                Text("VAL:")
                    .font(PixelTheme.pixelFont(size: 11))
                    .foregroundColor(PixelTheme.textSecondary)
                
                if showValue {
                    Text(item.value)
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.primary)
                        .shadow(color: PixelTheme.primary.opacity(0.3), radius: 2)
                        .lineLimit(1)
                } else {
                    Text(String(repeating: "*", count: min(item.value.count, 16)))
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textMuted)
                }
                
                Button(action: { showValue.toggle() }) {
                    Text(showValue ? "[HIDE]" : "[SHOW]")
                        .font(PixelTheme.pixelFont(size: 10))
                        .foregroundColor(PixelTheme.textPrimary)
                }
                .buttonStyle(.plain)
            }
            
            // Tags
            if !item.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(item.tags, id: \.self) { tag in
                        PixelTag(text: tag.uppercased(), color: PixelTheme.secondary)
                    }
                }
            }
        }
        .padding(10)
        .background(isHovering ? PixelTheme.primary.opacity(0.15) : PixelTheme.cardBackground)
        .pixelBorder(color: isHovering ? PixelTheme.primary : PixelTheme.borderHighlight, width: 1)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Pixel Add Sheet
struct PixelAddKeyValueSheet: View {
    @ObservedObject var kvStore: KeyValueStore
    @Binding var isPresented: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var tagsText: String = ""
    
    var tags: [String] {
        tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("[ ADD NEW KEY ]")
                .font(PixelTheme.pixelFontBold(size: 16))
                .foregroundColor(PixelTheme.primary)
                .shadow(color: PixelTheme.primary.opacity(0.5), radius: 4)
            
            PixelDivider(color: PixelTheme.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                // Key field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> KEY *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textPrimary)
                    TextField("ENTER_KEY_NAME", text: $key)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                }
                
                // Value field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> VALUE *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textPrimary)
                    SecureField("ENTER_SECRET_VALUE", text: $value)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                }
                
                // Description field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> DESC")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("OPTIONAL_DESCRIPTION", text: $description)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                }
                
                // Tags field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> TAGS")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("TAG1, TAG2, TAG3", text: $tagsText)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                    
                    // Existing tags
                    if !kvStore.allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                Text("EXISTING:")
                                    .font(PixelTheme.pixelFont(size: 10))
                                    .foregroundColor(PixelTheme.textSecondary)
                                ForEach(kvStore.allTags, id: \.self) { tag in
                                    Button(action: {
                                        if !tags.contains(tag) {
                                            tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                        }
                                    }) {
                                        PixelTag(text: tag.uppercased(), color: PixelTheme.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            
            PixelDivider(color: PixelTheme.borderHighlight)
            
            // Buttons
            HStack {
                Button(action: { isPresented = false }) {
                    Text("[ CANCEL ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.textPrimary)
                }
                .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground))
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.add(key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }) {
                    Text("[ SAVE ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background)
                }
                .buttonStyle(PixelButtonStyle(
                    backgroundColor: key.isEmpty || value.isEmpty ? PixelTheme.cardBackground : PixelTheme.primary,
                    foregroundColor: key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background
                ))
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(PixelTheme.background)
    }
}

// MARK: - Pixel Edit Sheet
struct PixelEditKeyValueSheet: View {
    @ObservedObject var kvStore: KeyValueStore
    let item: KeyValueItem
    @Binding var isPresented: Bool
    
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var description: String = ""
    @State private var tagsText: String = ""
    
    var tags: [String] {
        tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("[ EDIT KEY ]")
                .font(PixelTheme.pixelFontBold(size: 16))
                .foregroundColor(PixelTheme.warning)
                .shadow(color: PixelTheme.warning.opacity(0.5), radius: 4)
            
            PixelDivider(color: PixelTheme.warning)
            
            VStack(alignment: .leading, spacing: 12) {
                // Key field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> KEY *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textPrimary)
                    TextField("KEY", text: $key)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                }
                
                // Value field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> VALUE *")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textPrimary)
                    SecureField("VALUE", text: $value)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                }
                
                // Description field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> DESC")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("DESCRIPTION", text: $description)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                }
                
                // Tags field
                VStack(alignment: .leading, spacing: 4) {
                    Text("> TAGS")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.textSecondary)
                    TextField("TAG1, TAG2", text: $tagsText)
                        .font(PixelTheme.pixelFont(size: 13))
                        .foregroundColor(PixelTheme.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(PixelTheme.cardBackground)
                        .pixelBorder(color: PixelTheme.borderHighlight)
                    
                    // Existing tags
                    if !kvStore.allTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                Text("EXISTING:")
                                    .font(PixelTheme.pixelFont(size: 10))
                                    .foregroundColor(PixelTheme.textSecondary)
                                ForEach(kvStore.allTags, id: \.self) { tag in
                                    Button(action: {
                                        if !tags.contains(tag) {
                                            tagsText = tagsText.isEmpty ? tag : "\(tagsText), \(tag)"
                                        }
                                    }) {
                                        PixelTag(text: tag.uppercased(), color: PixelTheme.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            
            PixelDivider(color: PixelTheme.borderHighlight)
            
            // Buttons
            HStack {
                Button(action: { isPresented = false }) {
                    Text("[ CANCEL ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(PixelTheme.textPrimary)
                }
                .buttonStyle(PixelButtonStyle(backgroundColor: PixelTheme.cardBackground))
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: {
                    if !key.isEmpty && !value.isEmpty {
                        kvStore.update(id: item.id, key: key, value: value, description: description, tags: tags)
                        isPresented = false
                    }
                }) {
                    Text("[ UPDATE ]")
                        .font(PixelTheme.pixelFontBold(size: 12))
                        .foregroundColor(key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background)
                }
                .buttonStyle(PixelButtonStyle(
                    backgroundColor: key.isEmpty || value.isEmpty ? PixelTheme.cardBackground : PixelTheme.warning,
                    foregroundColor: key.isEmpty || value.isEmpty ? PixelTheme.textMuted : PixelTheme.background
                ))
                .keyboardShortcut(.return)
                .disabled(key.isEmpty || value.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(PixelTheme.background)
        .onAppear {
            key = item.key
            value = item.value
            description = item.description
            tagsText = item.tags.joined(separator: ", ")
        }
    }
}
