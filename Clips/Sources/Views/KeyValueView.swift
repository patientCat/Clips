import SwiftUI

struct KeyValueView: View {
    @ObservedObject var kvStore: KeyValueStore
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
            
            // Tag filter bar
            if !kvStore.allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        GlassTagButton(tag: "All", isSelected: selectedTag == nil, action: { selectedTag = nil })
                        ForEach(kvStore.allTags, id: \.self) { tag in
                            GlassTagButton(tag: tag.capitalized, isSelected: selectedTag == tag, action: { selectedTag = selectedTag == tag ? nil : tag })
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
            
            // Search bar
            GlassSearchBar(text: $searchText, placeholder: "Search keys...")
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            
            if filteredItems.isEmpty {
                GlassEmptyState(
                    icon: searchText.isEmpty && selectedTag == nil ? "key" : "magnifyingglass",
                    message: searchText.isEmpty && selectedTag == nil ? "Vault Empty" : "No Results",
                    submessage: searchText.isEmpty && selectedTag == nil ? "Add your first key" : "Try a different search"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredItems) { item in
                            GlassKeyValueRow(
                                item: item,
                                onCopy: { onCopyValue(item.value) },
                                onEdit: { editingItem = item },
                                onDelete: { kvStore.remove(id: item.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            GlassAddKeyValueSheet(kvStore: kvStore, isPresented: $showAddSheet)
        }
        .sheet(item: $editingItem) { item in
            GlassEditKeyValueSheet(kvStore: kvStore, item: item, isPresented: Binding(
                get: { editingItem != nil },
                set: { if !$0 { editingItem = nil } }
            ))
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
