import AppKit
import Combine

class ClipboardService: ObservableObject {
    @Published var currentContent: String?
    private var lastChangeCount: Int
    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    
    init() {
        self.lastChangeCount = pasteboard.changeCount
    }
    
    func startMonitoring() {
        // 启动定时器
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
        
        // 启动时立即读取当前剪贴板内容（同步设置，确保订阅者能收到）
        if let content = pasteboard.string(forType: .string) {
            print("📋 ClipboardService: 启动时读取到剪贴板内容: \(content.prefix(30))...")
            self.currentContent = content
        } else {
            print("📋 ClipboardService: 启动时剪贴板为空")
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForChanges() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let newContent = pasteboard.string(forType: .string) {
                print("📋 ClipboardService: 检测到剪贴板变化: \(newContent.prefix(30))...")
                self.currentContent = newContent
            }
        }
    }
    
    func copyToClipboard(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        // Update change count to avoid self-triggering loops if necessary, 
        // though the check loop handles it by updating lastChangeCount after detection.
        // But for immediate consistency, we might want to update our local knowledge
        // or just let the loop catch it (which is safer to ensure it really happened).
    }
}
