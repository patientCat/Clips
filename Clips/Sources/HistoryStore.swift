import Foundation
import Combine
import AppKit

class HistoryStore: ObservableObject {
    @Published var history: [ClipboardItem] = []
    private let maxItems = 50
    private let storageKey = "ClipsHistory"
    private var cancellables = Set<AnyCancellable>()
    
    init(clipboardService: ClipboardService) {
        load()
        print("📋 HistoryStore 初始化，已加载 \(history.count) 条历史记录")
        
        // 订阅文本变化
        clipboardService.$currentTextContent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                print("📋 收到文本内容: \(content.prefix(50))...")
                self?.addTextItem(content)
            }
            .store(in: &cancellables)
        
        // 订阅图片变化
        clipboardService.$currentImageContent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                print("📋 收到图片内容")
                self?.addImageItem(image)
            }
            .store(in: &cancellables)
    }
    
    private func addTextItem(_ content: String) {
        // 只和最近一条比较，相同则跳过
        if let first = history.first, 
           first.contentType == .text && first.content == content {
            print("📋 内容与上一条相同，跳过")
            return
        }
        
        print("📋 添加新文本记录: \(content.prefix(30))..., 当前数量: \(history.count)")
        let newItem = ClipboardItem(content: content)
        insertItem(newItem)
    }
    
    private func addImageItem(_ image: NSImage) {
        // 创建图片项
        let newItem = ClipboardItem(image: image)
        
        // 检查是否与上一条图片相同（通过数据比较）
        if let first = history.first,
           first.contentType == .image,
           first.imageData == newItem.imageData {
            print("📋 图片与上一条相同，跳过")
            return
        }
        
        print("📋 添加新图片记录, 当前数量: \(history.count)")
        insertItem(newItem)
    }
    
    private func insertItem(_ item: ClipboardItem) {
        // 显式触发 UI 更新
        objectWillChange.send()
        history.insert(item, at: 0)
        
        // Enforce limit
        if history.count > maxItems {
            history = Array(history.prefix(maxItems))
        }
        
        print("📋 添加后数量: \(history.count)")
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            history = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    func clear() {
        history.removeAll()
        save()
    }
}
