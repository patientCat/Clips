import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct FileShelfView: View {
    @ObservedObject var store: FileShelfStore
    @State private var selection = Set<UUID>()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            GlassSectionHeader(
                title: "File Shelf",
                count: store.files.count,
                actionTitle: "Clear",
                action: { store.clear() }
            )
            
            // Content
            ZStack {
                // Background drop target
                Color.clear
                    .contentShape(Rectangle())
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }

                if store.files.isEmpty {
                    GlassEmptyState(
                        icon: "folder.badge.plus",
                        message: "Drop Files Here",
                        submessage: "Drag files to add them to the shelf"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(store.files) { file in
                                GlassFileShelfRow(
                                    file: file,
                                    isSelected: selection.contains(file.id),
                                    allSelectedFiles: selection.count > 1 && selection.contains(file.id)
                                        ? store.files.filter { selection.contains($0.id) }
                                        : [file]
                                )
                                .onTapGesture {
                                    handleTap(file: file)
                                }
                                .contextMenu {
                                    fileContextMenu(file: file)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func handleTap(file: ShelvedFile) {
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
    
    @ViewBuilder
    private func fileContextMenu(file: ShelvedFile) -> some View {
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

// MARK: - Glass File Shelf Row
struct GlassFileShelfRow: View {
    let file: ShelvedFile
    let isSelected: Bool
    let allSelectedFiles: [ShelvedFile]
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
            
            Text(file.url.lastPathComponent)
                .font(GlassmorphismTheme.glassFont(size: 13))
                .foregroundColor(GlassmorphismTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
            
            if isHovering {
                Image(systemName: "hand.draw")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(GlassmorphismTheme.textMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(GlassmorphismTheme.primary.opacity(0.15))
                } else if isHovering {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.05))
                }
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? GlassmorphismTheme.primary.opacity(0.5) : Color.white.opacity(isHovering ? 0.25 : 0.15),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: Color.black.opacity(isHovering ? 0.1 : 0.05), radius: isHovering ? 8 : 4, x: 0, y: isHovering ? 4 : 2)
        .contentShape(Rectangle())
        .onDrag {
            createDragProvider(for: allSelectedFiles)
        }
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
    
    private func createDragProvider(for files: [ShelvedFile]) -> NSItemProvider {
        let urls = files.map { $0.url }
        guard let firstURL = urls.first else { return NSItemProvider() }
        
        let provider = NSItemProvider()
        provider.registerFileRepresentation(
            forTypeIdentifier: UTType.fileURL.identifier,
            fileOptions: [.openInPlace],
            visibility: .all
        ) { completion in
            completion(firstURL, true, nil)
            return nil
        }
        provider.registerObject(firstURL as NSURL, visibility: .all)
        provider.suggestedName = firstURL.lastPathComponent
        return provider
    }
}
