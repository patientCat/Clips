import SwiftUI
import AppKit

enum ClipsTab: String, CaseIterable {
    case history = "CLIPS"
    case favorites = "FAVS"
    case keyValue = "KEYS"
    case json = "JSON"
    case reminder = "TIMER"
    case shelf = "SHELF"
}

struct MenuBarView: View {
    @ObservedObject var historyStore: HistoryStore
    @ObservedObject var kvStore: KeyValueStore
    @ObservedObject var reminderStore: RestReminderStore
    @ObservedObject var fileShelfStore: FileShelfStore
    @ObservedObject var plantStore: PlantGrowthStore
    var onCopy: (String) -> Void
    var onCopyImage: ((NSImage) -> Void)?
    var onQuit: () -> Void
    
    @State private var selectedTab: ClipsTab = .history
    @State private var searchText: String = ""
    @State private var showHelp: Bool = false
    @State private var showPlant: Bool = false
    
    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return historyStore.history
        }
        return historyStore.history.filter { 
            $0.content.localizedCaseInsensitiveContains(searchText) 
        }
    }
    
    private var theme: ThemeColors { Theme.current }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Tab bar (仅在非植物/帮助模式时显示)
            if !showPlant && !showHelp {
                tabBarView
            }
            
            // Content area
            ZStack {
                GlassGradientBackground()
                
                if showPlant {
                    PlantGrowthView(store: plantStore)
                } else if showHelp {
                    HelpView()
                } else if selectedTab == .history {
                    historyView
                } else if selectedTab == .favorites {
                    favoritesView
                } else if selectedTab == .keyValue {
                    KeyValueView(kvStore: kvStore, onCopyValue: onCopy)
                } else if selectedTab == .json {
                    JsonFormatterView(onCopy: onCopy)
                } else if selectedTab == .reminder {
                    RestReminderView(store: reminderStore)
                } else if selectedTab == .shelf {
                    FileShelfView(store: fileShelfStore)
                }
            }
            
            // Footer
            footerView
        }
        .background(
            ZStack {
                GlassGradientBackground()
                Rectangle().fill(.ultraThinMaterial)
            }
        )
        .frame(minWidth: 580, maxWidth: .infinity, minHeight: 650, maxHeight: .infinity)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("L-Tools")
                .font(GlassmorphismTheme.glassFontBold(size: 18))
                .foregroundColor(GlassmorphismTheme.textPrimary)
            
            Spacer()
            
            // Plant button (绿色植物图标)
            Button(action: { 
                showPlant.toggle()
                if showPlant { showHelp = false }
            }) {
                Image(systemName: showPlant ? "leaf.fill" : "leaf")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(showPlant ? Color.green : GlassmorphismTheme.textMuted)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
            .padding(.trailing, 4)
            
            // Help button
            Button(action: { 
                showHelp.toggle()
                if showHelp { showPlant = false }
            }) {
                Image(systemName: showHelp ? "questionmark.circle.fill" : "questionmark.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(showHelp ? GlassmorphismTheme.primary : GlassmorphismTheme.textMuted)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
            .padding(.trailing, 8)
            
            // Decorative indicators
            HStack(spacing: 4) {
                Circle().fill(GlassmorphismTheme.danger).frame(width: 10, height: 10)
                    .shadow(color: GlassmorphismTheme.danger.opacity(0.4), radius: 4)
                Circle().fill(GlassmorphismTheme.warning).frame(width: 10, height: 10)
                    .shadow(color: GlassmorphismTheme.warning.opacity(0.4), radius: 4)
                Circle().fill(GlassmorphismTheme.primary).frame(width: 10, height: 10)
                    .shadow(color: GlassmorphismTheme.primary.opacity(0.4), radius: 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Color.white.opacity(0.05))
            }
        )
    }
    
    // MARK: - Tab Bar View
    private var tabBarView: some View {
        HStack(spacing: 6) {
            ForEach(ClipsTab.allCases, id: \.self) { tab in
                GlassTabButton(
                    icon: tabIcon(for: tab),
                    title: tab.rawValue.capitalized,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Rectangle().fill(.ultraThinMaterial))
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        HStack {
            Circle()
                .fill(GlassmorphismTheme.primary)
                .frame(width: 6, height: 6)
                .shadow(color: GlassmorphismTheme.primary.opacity(0.5), radius: 4)
            Text("Ready")
                .font(GlassmorphismTheme.glassFont(size: 12))
                .foregroundColor(GlassmorphismTheme.textMuted)
            
            Spacer()
            
            Button(action: onQuit) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 11, weight: .medium))
                    Text("Quit")
                        .font(GlassmorphismTheme.glassFont(size: 11))
                }
                .foregroundColor(GlassmorphismTheme.danger)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Rectangle().fill(.ultraThinMaterial))
    }
    
    // MARK: - Tab Icon
    private func tabIcon(for tab: ClipsTab) -> String {
        switch tab {
        case .history: return "doc.on.clipboard"
        case .favorites: return "star.fill"
        case .keyValue: return "key"
        case .json: return "curlybraces"
        case .reminder: return "bell"
        case .shelf: return "folder"
        }
    }
    
    // MARK: - History View
    private var historyView: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(
                title: "Clipboard History",
                count: historyStore.history.count,
                actionTitle: "Clear",
                action: { historyStore.clear() }
            )
            
            GlassSearchBar(text: $searchText, placeholder: "Search clips...")
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            
            if filteredHistory.isEmpty {
                GlassEmptyState(
                    icon: searchText.isEmpty ? "doc.on.clipboard" : "magnifyingglass",
                    message: searchText.isEmpty ? "No Clipboard History" : "No Results Found",
                    submessage: searchText.isEmpty ? "Copy something to get started" : "Try a different search term"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredHistory) { item in
                            GlassClipboardRow(
                                item: item,
                                showFavoriteButton: true,
                                onCopy: {
                                    if item.contentType == .text {
                                        onCopy(item.content)
                                    } else if let image = item.image {
                                        onCopyImage?(image)
                                    }
                                },
                                onToggleFavorite: {
                                    historyStore.toggleFavorite(for: item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    // MARK: - Favorites View
    private var favoritesView: some View {
        VStack(spacing: 0) {
            GlassSectionHeader(
                title: "Favorites",
                count: historyStore.favorites.count,
                actionTitle: "Clear",
                action: { historyStore.clearFavorites() }
            )
            
            if historyStore.favorites.isEmpty {
                GlassEmptyState(
                    icon: "star",
                    message: "No Favorites Yet",
                    submessage: "Star items to add them here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(historyStore.favorites) { item in
                            GlassClipboardRow(
                                item: item,
                                showFavoriteButton: true,
                                onCopy: {
                                    if item.contentType == .text {
                                        onCopy(item.content)
                                    } else if let image = item.image {
                                        onCopyImage?(image)
                                    }
                                },
                                onToggleFavorite: {
                                    historyStore.toggleFavorite(for: item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
