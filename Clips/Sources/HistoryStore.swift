import Foundation
import Combine

class HistoryStore: ObservableObject {
    @Published var history: [ClipboardItem] = []
    private let maxItems = 50
    private let storageKey = "ClipsHistory"
    private var cancellables = Set<AnyCancellable>()
    
    init(clipboardService: ClipboardService) {
        load()
        print("📋 HistoryStore 初始化，已加载 \(history.count) 条历史记录")
        
        clipboardService.$currentContent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                print("📋 收到剪贴板内容: \(content.prefix(50))...")
                self?.addItem(content)
            }
            .store(in: &cancellables)
    }
    
    private func addItem(_ content: String) {
        // 只和最近一条比较，相同则跳过
        if let first = history.first, first.content == content {
            print("📋 内容与上一条相同，跳过")
            return
        }
        
        print("📋 添加新记录: \(content.prefix(30))..., 当前数量: \(history.count)")
        let newItem = ClipboardItem(content: content)
        
        // 显式触发 UI 更新
        objectWillChange.send()
        history.insert(newItem, at: 0)
        
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
