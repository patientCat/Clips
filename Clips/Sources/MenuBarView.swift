import SwiftUI

struct MenuBarView: View {
    @ObservedObject var historyStore: HistoryStore
    var onCopy: (String) -> Void
    var onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Clips History (\(historyStore.history.count))")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Button("Clear") {
                    historyStore.clear()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if historyStore.history.isEmpty {
                VStack {
                    Spacer()
                    Text("暂无剪贴板记录")
                        .foregroundColor(.secondary)
                    Text("复制内容后会自动显示")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxHeight: 400)
            } else {
                List {
                    ForEach(historyStore.history) { item in
                        Button(action: {
                            onCopy(item.content)
                        }) {
                            HStack {
                                Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxHeight: 400)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Quit Clips") {
                    onQuit()
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 300)
    }
}
