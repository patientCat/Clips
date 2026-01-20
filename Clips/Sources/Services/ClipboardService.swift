import AppKit
import Combine

class ClipboardService: ObservableObject {
    @Published var currentTextContent: String?
    @Published var currentImageContent: NSImage?
    
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
        
        // 启动时立即读取当前剪贴板内容
        readCurrentContent()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func readCurrentContent() {
        // 优先检查图片
        if let image = getImageFromPasteboard() {
            print("📋 ClipboardService: 启动时读取到图片")
            self.currentImageContent = image
            self.currentTextContent = nil
        } else if let content = pasteboard.string(forType: .string) {
            print("📋 ClipboardService: 启动时读取到文本: \(content.prefix(30))...")
            self.currentTextContent = content
            self.currentImageContent = nil
        } else {
            print("📋 ClipboardService: 启动时剪贴板为空")
        }
    }
    
    private func checkForChanges() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            
            // 优先检查图片
            if let image = getImageFromPasteboard() {
                print("📋 ClipboardService: 检测到图片变化")
                self.currentImageContent = image
                self.currentTextContent = nil
            } else if let newContent = pasteboard.string(forType: .string) {
                print("📋 ClipboardService: 检测到文本变化: \(newContent.prefix(30))...")
                self.currentTextContent = newContent
                self.currentImageContent = nil
            }
        }
    }
    
    private func getImageFromPasteboard() -> NSImage? {
        // 检查多种图片类型
        let imageTypes: [NSPasteboard.PasteboardType] = [.png, .tiff, .pdf]
        
        for type in imageTypes {
            if let data = pasteboard.data(forType: type),
               let image = NSImage(data: data) {
                return image
            }
        }
        
        // 检查文件 URL（图片文件）
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            for url in urls {
                let imageExtensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp"]
                if imageExtensions.contains(url.pathExtension.lowercased()),
                   let image = NSImage(contentsOf: url) {
                    return image
                }
            }
        }
        
        return nil
    }
    
    func copyToClipboard(_ content: String) {
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
    
    func copyImageToClipboard(_ image: NSImage) {
        pasteboard.clearContents()
        if let tiffData = image.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
        }
    }
}
