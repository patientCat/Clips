import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct FileShelfView: View {
    @ObservedObject var store: FileShelfStore
    @State private var selection = Set<UUID>()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("> FILE_SHELF")
                    .font(PixelTheme.pixelFontBold(size: 12))
                    .foregroundColor(PixelTheme.primary)
                Text("[\(store.files.count)]")
                    .font(PixelTheme.pixelFont(size: 12))
                    .foregroundColor(PixelTheme.accent)
                Spacer()
                Button(action: { store.clear() }) {
                    Text("[CLR]")
                        .font(PixelTheme.pixelFont(size: 11))
                        .foregroundColor(PixelTheme.danger)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            PixelDivider()
                .padding(.vertical, 4)
            
            // Content
            ZStack {
                // Background drop target
                Color.clear
                    .contentShape(Rectangle())
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }

                if store.files.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Text("╔══════════════════╗")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.border)
                        Text("║  DROP FILES HERE ║")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.textSecondary)
                        Text("╚══════════════════╝")
                            .font(PixelTheme.pixelFont(size: 12))
                            .foregroundColor(PixelTheme.border)
                        Spacer()
                    }
                    .allowsHitTesting(false)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(store.files) { file in
                                FileShelfRow(
                                    file: file,
                                    isSelected: selection.contains(file.id),
                                    allSelectedFiles: selection.count > 1 && selection.contains(file.id)
                                        ? store.files.filter { selection.contains($0.id) }
                                        : [file]
                                )
                                .onTapGesture {
                                    if NSEvent.modifierFlags.contains(.command) {
                                        if selection.contains(file.id) {
                                            selection.remove(file.id)
                                        } else {
                                            selection.insert(file.id)
                                        }
                                    } else {
                                        selection = [file.id]
                                    }
                                }
                                .contextMenu {
                                    Button("Delete") {
                                        if selection.contains(file.id) && selection.count > 1 {
                                            for id in selection {
                                                store.removeFile(id: id)
                                            }
                                            selection.removeAll()
                                        } else {
                                            store.removeFile(id: file.id)
                                        }
                                    }
                                    Button("Show in Finder") {
                                        NSWorkspace.shared.activateFileViewerSelecting([file.url])
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .background(PixelTheme.background)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        store.ingestFile(url: url)
                    }
                }
            }
        }
        return true
    }
}

// MARK: - File Shelf Row with proper drag support
struct FileShelfRow: View {
    let file: ShelvedFile
    let isSelected: Bool
    let allSelectedFiles: [ShelvedFile]
    
    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(file.url.lastPathComponent)
                .font(PixelTheme.pixelFont(size: 12))
                .foregroundColor(PixelTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isSelected ? PixelTheme.primary.opacity(0.2) : PixelTheme.cardBackground)
        .pixelBorder(color: isSelected ? PixelTheme.primary : PixelTheme.borderHighlight, width: 1)
        .contentShape(Rectangle())
        .onDrag {
            createDragProvider(for: allSelectedFiles)
        }
    }
    
    private func createDragProvider(for files: [ShelvedFile]) -> NSItemProvider {
        let urls = files.map { $0.url }
        
        // Use the first file's URL for the provider
        guard let firstURL = urls.first else {
            return NSItemProvider()
        }
        
        let provider = NSItemProvider()
        
        // Register file promise - this allows Finder to receive the file
        provider.registerFileRepresentation(
            forTypeIdentifier: UTType.fileURL.identifier,
            fileOptions: [.openInPlace],
            visibility: .all
        ) { completion in
            completion(firstURL, true, nil)
            return nil
        }
        
        // Also register as URL for compatibility
        provider.registerObject(firstURL as NSURL, visibility: .all)
        
        // Set suggested name
        provider.suggestedName = firstURL.lastPathComponent
        
        return provider
    }
}